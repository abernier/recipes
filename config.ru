require 'rubygems'
require 'sinatra'
 
set :env, :production
disable :run

require 'recipes'
run Sinatra::Application
