require 'wordfun/query'
require 'wordfun/result'

require 'haml'
require 'wordsearch'
require 'lingua/stemmer'
require 'wordnet'
require 'mysql2'
require 'json'
require 'wordfun'

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
    words = Enumerator.new(wordsearch, query.command, query.word).map do |word|
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

    results = disambiguate(results, query.context) if query.context?

    results.map(&:to_api)
  end

  def preview(query)
    result = cmd(query).truncate(MAX_PREVIEW)
    matches = pluralize(result.count, "match", "matches")
    "#{query.word_with_lengths}: #{matches} (#{result.as_list})"
  end

  def disambiguate(results, context)
    if context && !context.empty?
      with_db do |client|
        words = results.map { |r| r[:word] }
        quoted_words = words.map { |w| "'#{w.upcase.gsub(/[^A-Z]/, '')}'" }.join(",")
        rows = client.query("select word, count(*) as N, clue from clues where match(clue) against ('#{client.escape(context)}') and clue not like '%\\_\\_\\_%' and clue not like '%--%' and word in (#{quoted_words}) group by word order by N desc", as: :hash).to_a
        matching_words = []
        rows.each do |row|
          word = row["word"]
          matches, results = results.partition { |r| r[:word].upcase.gsub(/[^A-Z]/, '') == word }
          matches.each { |r| r[:defn] = row["clue"] }
          matching_words += matches
        end
        results = matching_words + results
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
    client = Mysql2::Client.new(
      host: "localhost",
      database: "wordfun",
      username: "pete"
    )
    yield client
    client.close
  end
end

