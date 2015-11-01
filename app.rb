$: << File.join(File.dirname(__FILE__), "lib")

require 'sinatra/asset_pipeline/task.rb'
require 'sinatra/base'
require 'sinatra/asset_pipeline'
require 'wordfun'
require 'thesaurus'

class App < Sinatra::Base
  set :assets_js_compressor, :uglifier
  register Sinatra::AssetPipeline
  Sinatra::AssetPipeline::Task.define! App

  get '/' do
    haml :index
  end

  get '/preview/thesaurus' do
    query = params[:q]
    entries = Thesaurus.lookup(query)
    root_words = entries.map(&:root) - [query]
    if root_words.any?
      words = root_words
    else
      words = entries.select { |entry| entry.root == query }.flat_map(&:words)
    end
    { query: query, words: words }.to_json
  end

  get '/preview/:cmd' do
    query = Wordfun::Query.new
    query.command = params[:cmd]
    query.word = params[:q]
    query.context = params[:c]

    Wordfun.preview(query)
  end

  get '/words/:cmd' do
    query = Wordfun::Query.new
    query.command = params[:cmd]
    query.word = params[:q]
    query.context = params[:c]

    results = Wordfun.full_list(query)

    content_type :json
    { words: results }.to_json
  end
end
