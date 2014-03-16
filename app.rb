class App < Sinatra::Base
  set :assets_js_compressor, :uglifier
  register Sinatra::AssetPipeline
  Sinatra::AssetPipeline::Task.define! App

  get '/' do
    haml :index
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
