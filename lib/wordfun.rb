require 'wordfun/query'
require 'wordfun/result'

require 'haml'
require 'wordsearch'
require 'lingua/stemmer'
require 'wordnet'
require 'mysql2'
require 'json'
require 'wordfun'
require 'yaml'

class Wordfun
  MAX_PREVIEW = 25
  MAX_DEFINE = 100

  def self.full_list(query)
    new.full_list(query)
  end

  def self.preview(query)
    new.preview(query)
  end

  def cmd(query, wordsearch=nil)
    wordsearch ||= Wordsearch.new("/usr/share/dict/anadict")
    words = wordsearch.to_enum(query.command, query.word).map do |word|
      word.force_encoding("WINDOWS-1252").encode("UTF-8")
    end

    Wordfun::Result.new(words.to_a)
  end

  def full_list(query)
    words = cmd(query)

    results = []

    lex = WordNet::Lexicon.new
    stemmer = Lingua::Stemmer.new(lang: "en")

    words.each.with_index do |word, count|
      if count < MAX_DEFINE
        entry = lex[word.downcase] || lex[stemmer.stem(word.downcase)]
        if entry
          word = word.define(entry.definition)
        end
      end
      results << word
    end

    results = disambiguate(results, query)

    results.map(&:to_api)
  end

  def preview(query)
    result = cmd(query).truncate(MAX_PREVIEW)
    matches = pluralize(result.count, "match", "matches")
    "#{query.word_with_lengths}: #{matches} (#{result.as_list})"
  end

  def disambiguate(results, query)
    if query.context?
      with_db do |client|
        q = query.word.gsub(".", "_")
        rows = client.query("select word, count(*) as score, definition from words, definitions where definitions.word_id = words.id and match(definition) against ('#{client.escape(query.context)}') and words.letters like '#{client.escape(q)}' and words.length = #{q.length} group by word", as: :hash).to_a

        results = rows.map { |row| w = Word.new(row["word"]).define(row["definition"]); w.score = row["score"]; w }.sort_by(&:score).reverse
      end
    end
    results
  end

  def pluralize(n, noun, plural)
    if n.to_i == 1
      "1 #{noun}"
    else
      "#{n} #{plural}"
    end
  end

  def with_db
    dbconfig = YAML.load_file("config/database.yml")
    client = Mysql2::Client.new(dbconfig)
    yield client
    client.close
  end
end

