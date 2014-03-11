require 'sinatra/base'
require 'sinatra/asset_pipeline'
require 'haml'
require 'wordsearch'
require 'lingua/stemmer'
require 'wordnet'
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
    full_list('an', params[:q])
  end

  get '/words/fw' do
    full_list('fw', params[:q])
  end

  get '/words/cr' do
    full_list('cr', params[:q])
  end

  get '/preview/an' do
    preview('an', params[:q])
  end

  get '/preview/fw' do
    preview('fw', params[:q])
  end

  get '/preview/cr' do
    preview('cr', params[:q])
  end

  private

  def cmd(name, query)
    query = query.downcase.gsub(" ", "").gsub("…", "...").gsub("?", ".")
    words = []

    Wordsearch.new("/usr/share/dict/anadict").public_send(name, query) do |word|
      words << word.force_encoding("WINDOWS-1252").encode("UTF-8")
    end

    words
  end

  def full_list(name, query)
    words = cmd(name, query)
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

    content_type :json
    { words: results }.to_json
  end

  def preview(name, query)
    words = cmd(name, query)
    wc = words.count
    if wc > MAX_PREVIEW
      words = words.take(MAX_PREVIEW) + ["..."]
    end
    lengths = query.split("/").map(&:length).join(",")
    "#{query} (#{lengths}): #{pluralize(wc, "match", "matches")} (#{words.join(", ")})"
  end

  def pluralize(n, noun, plural)
    if n.to_i == 1
      "1 #{noun}"
    else
      "#{n} #{plural}"
    end
  end
end
