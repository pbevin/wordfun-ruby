require 'sinatra/base'
require 'sinatra/asset_pipeline'
require 'haml'
require 'shellwords'

class Wordfun < Sinatra::Base
  MAX_PREVIEW = 25

  set :assets_js_compressor, :uglifier
  register Sinatra::AssetPipeline

  get '/' do
    haml :index
  end

  get '/words/an' do
    cmd('an', params[:q])
  end

  get '/words/fw' do
    cmd('fw', params[:q])
  end

  get '/words/cr' do
    cmd('fw -c', params[:q])
  end

  get '/preview/an' do
    preview('an', params[:q])
  end

  get '/preview/fw' do
    preview('fw', params[:q])
  end

  get '/preview/cr' do
    preview('fw -c', params[:q])
  end

  private

  def cmd(name, query)
    query = query.downcase.gsub(" ", "").gsub("…", "...")
    cmd = "#{name} #{Shellwords.escape(query)}"

    `#{cmd}`.force_encoding("WINDOWS-1252").encode("UTF-8")
  end

  def preview(name, query)
    words = cmd(name, query).lines
    wc = words.count
    if wc > MAX_PREVIEW
      words = words.take(MAX_PREVIEW) + ["..."]
    end
    words.map!(&:strip)
    pluralize(wc, "word") + " (#{words.join(", ")})"
  end

  def pluralize(n, noun)
    if n.to_i == 1
      "1 #{noun}"
    else
      "#{n} #{noun}s"
    end
  end
end
