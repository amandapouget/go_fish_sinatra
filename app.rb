Dir.glob('lib/**/*.rb') { |f| require_relative f }
require 'sinatra'
require 'sinatra/reloader'
also_reload '**/*.rb'

get '/' do
  erb :index
end
