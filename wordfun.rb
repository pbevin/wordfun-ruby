require 'sinatra/base'
require 'sinatra/asset_pipeline'
require 'haml'
require 'wordsearch'
require 'lingua/stemmer'
require 'wordnet'
require 'mysql2'
require 'json'

class Wordfun < Sinatra::Base
  MAX_PREVIEW = 25
  MAX_DEFINE = 100

  set :assets_js_compressor, :uglifier
  register Sinatra::AssetPipeline

  get '/' do
    haml :index
  end

  get '/words/an' do
    full_list('an', params[:q], params[:c])
  end

  get '/words/fw' do
    full_list('fw', params[:q], params[:c])
  end

  get '/words/cr' do
    full_list('fw -c', params[:q], params[:c])
  end

  get '/preview/an' do
    preview('an', params[:q], params[:c])
  end

  get '/preview/fw' do
    preview('fw', params[:q], params[:c])
  end

  get '/preview/cr' do
    preview('fw -c', params[:q], params[:c])
  end

  private

  def cmd(name, query, context)
    query = query.downcase.gsub(" ", "").gsub("…", "...").gsub("?", ".")
    words = []

    Wordsearch.new("/usr/share/dict/anadict").public_send(name, query) do |word|
      words << word.force_encoding("WINDOWS-1252").encode("UTF-8")
    end

    words
  end

  def full_list(name, query, context)
    words = cmd(name, query, context)
    results = []

    lex = WordNet::Lexicon.new
    stemmer = Lingua::Stemmer.new(lang: "en")

    words.each_with_index do |word, count|
      result = { word: word }
      if count < MAX_DEFINE
        entry = lex[word.downcase] || lex[stemmer.stem(word.downcase)]
        if entry
          result[:defn] = entry.definition
        end
      end
      results << result
    end

    p 1
    results = disambiguate(results, context)

    content_type :json
    { words: results }.to_json
  end

  def preview(name, query, context)
    words = cmd(name, query, context)
    wc = words.count
    if wc > MAX_PREVIEW
      words = words.take(MAX_PREVIEW) + ["..."]
    end
    lengths = query.split("/").map(&:length).join(",")
    "#{query} (#{lengths}): #{pluralize(wc, "match", "matches")} (#{words.join(", ")})"
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
