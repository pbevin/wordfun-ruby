$: << 'lib'

require 'sinatra'
require 'sinatra/asset_pipeline/task.rb'
require 'sinatra/base'
require 'sinatra/asset_pipeline'
require 'wordfun'
require './app'

use Rack::Lint
run App
