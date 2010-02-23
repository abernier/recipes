require 'rubygems'
require 'sinatra'
 
set :environment, :development
disable :run

require 'recipes'
run Sinatra::Application
