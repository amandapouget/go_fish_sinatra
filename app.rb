Dir.glob('lib/**/*.rb') { |file| require_relative file } # Is there a better way to require all the lib files?
require 'slim'
require 'sinatra'
require 'sinatra/reloader'
also_reload 'lib/*.rb'

NUM_PLAYERS = 5

get '/' do
end

get '/player/:player_id' do
  user1 = User.new(name: "Amanda")
  user2 = User.new(name: "Vianney")
  user3 = User.new(name: "Frederique")
  user4 = User.new(name: "JeanLuc")
  user5 = User.new(name: "Priscille")
  @match = Match.new([user1, user2, user3, user4, user5])
  player_id = params["player_id"].to_i
  if player_id < @match.num_players
    @player = @match.players[player_id]
    @opponents = @match.opponents(@player)
    slim :player
  else
    slim :no_player
  end
end
