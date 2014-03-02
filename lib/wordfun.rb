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
        canonical_words = results.inject({}) { |dict, word| dict[word.canonical] = word; dict }
        quoted_words = canonical_words.keys.map { |w| "'#{w}'" }.join(",")
        rows = client.query("select word, count(*) as score, clue from clues where match(clue) against ('#{client.escape(query.context)}') and clue not like '%\\_\\_\\_%' and clue not like '%--%' and word in (#{quoted_words}) group by word", as: :hash).to_a
        rows.each do |row|
          cword = row["word"]
          canonical_words[cword] = canonical_words[cword].define(row["clue"])
          canonical_words[cword].score = row["score"]
        end
        results = results.map { |word| canonical_words[word.canonical] || word }

        results.each do |word|
          if word.score == 0 && word.definition.include?(query.context)
            word.score = 1
          end
        end
        results = results.each.with_index.sort_by { |word, idx| [-word.score, idx] }.map(&:first)
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

