require 'sinatra'
require 'sinatra/asset_pipeline/task.rb'
require './wordfun'

Sinatra::AssetPipeline::Task.define! Wordfun

use Rack::Lint
run Wordfun
