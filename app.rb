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

  get '/cryptogram' do
    haml :cryptogram
  end

  get '/preview/thesaurus' do
    query = Wordfun::Query.from_web_params(params)
    results = Wordfun.thesaurus_preview(query)

    content_type :json
    results.to_json
  end

  get '/preview/:cmd' do
    query = Wordfun::Query.from_web_params(params)
    Wordfun.preview(query)
  end

  get '/words/:cmd' do
    query = Wordfun::Query.from_web_params(params)
    results = Wordfun.full_list(query)

    content_type :json
    { words: results }.to_json
  end
end
