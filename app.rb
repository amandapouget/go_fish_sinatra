Dir.glob('lib/**/*.rb') { |file| require_relative file } # Is there a better way to require all the lib files?
require 'sinatra'
require 'sinatra/reloader'
also_reload 'lib/*.rb'

NUM_PLAYERS = 5

get '/' do
end

get '/player/:player_id' do
  @player_id = params["player_id"].to_i
  @other_player_ids = (0..(NUM_PLAYERS - 1)).to_a.tap { |player_ids| player_ids.delete(@player_id) }
  if @player_id + 1 <= NUM_PLAYERS
    erb :player
  else
    erb :no_player
  end
end
