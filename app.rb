Dir.glob('lib/**/*.rb') { |file| require_relative file } # Is there a better way to require all the lib files?
require 'slim'
require 'sinatra'
require 'sinatra/reloader'
also_reload 'lib/*.rb'

MIN_PLAYERS = 2
MAX_PLAYERS = 5
PLAYER_RANGE = (MIN_PLAYERS..MAX_PLAYERS)

get '/' do
  slim :index
end

get '/:match_id/player/:player_id' do
  match_id = params["match_id"].to_i
  player_id = params["player_id"].to_i
  @match = Match.find_by_obj_id(match_id)
  @match = Match.fake(match_id) if @match == nil
  @player = @match.players[player_id]
  @opponents = @match.opponents(@player) if @player
  slim :player
end

post '/start_game' do
  num_players = params['num_players'].to_i
  users = [User.new(name: params["name"]), User.new(name: "Vianney"), User.new(name: "Frederique"), User.new(name: "JeanLuc"), User.new(name: "Priscille")]
  match = Match.new(users[0...num_players])
  match.game.deal
  redirect "#{match.object_id}/player/0"
end
