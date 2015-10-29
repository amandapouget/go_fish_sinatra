Dir.glob('lib/**/*.rb') { |file| require_relative file } # Is there a better way to require all the lib files?
require 'sinatra'
require 'sinatra/reloader'
also_reload '**/*.rb'

get '/' do
  erb :index
end
