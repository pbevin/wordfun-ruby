require 'sinatra'
require './wordfun'

use Rack::Lint
run Wordfun
