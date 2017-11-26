require 'wordfun/query'
require 'wordfun/result'

require 'haml'
require 'wordsearch'
require 'lingua/stemmer'
require 'wordnet'
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

  def self.thesaurus_preview(query)
    new.thesaurus_preview(query)
  end

  def cmd(query, wordsearch=nil)
    wordsearch ||= Wordsearch.new(ENV["DICT"] || "/usr/share/dict/anadict")
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

    results.map(&:to_api)
  end

  def preview(query)
    result = cmd(query).truncate(MAX_PREVIEW)
    matches = pluralize(result.count, "match", "matches")
    "#{query.word_with_lengths}: #{matches} (#{result.as_list})"
  end

  def thesaurus_preview(query)
    word = query.word.to_s.strip.downcase
    entries = Thesaurus.lookup(word)
    root_words = entries.map(&:root) - [word]
    if root_words.any?
      words = root_words
    else
      words = entries.select { |entry| entry.root == word }.flat_map(&:words)
    end

    {
      query: query.word,
      count: pluralize(words.length, "match", "matches"),
      words: group_by_length(words)
    }
  end

  def pluralize(n, noun, plural)
    if n.to_i == 1
      "1 #{noun}"
    else
      "#{n} #{plural}"
    end
  end

  def group_by_length(results)
    results.group_by { |word| word.split.map(&:length) }
      .to_a
      .sort_by { |len, words| len.inject(:+) }
      .map { |len, words| [ display_length(len), words ] }
  end

  def display_length(lengths)
    if lengths.size == 1
      lengths.first.to_s
    else
      total = lengths.inject(:+)
      "#{total} (#{lengths.join(",")})"
    end
  end
end

