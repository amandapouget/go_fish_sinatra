Dir.glob('lib/**/*.rb') { |file| require_relative file } # Is there a better way to require all the lib files?
require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'pusher'
also_reload 'lib/*.rb'

def reset_pending
  (PLAYER_RANGE).each { |num_players| PENDING_USERS[num_players] = [] }
end

MIN_PLAYERS = 2
MAX_PLAYERS = 5
PLAYER_RANGE = (MIN_PLAYERS..MAX_PLAYERS)
PENDING_USERS = {}.tap { |pending_users| (PLAYER_RANGE).each { |num_players| pending_users[num_players] = [] } }
Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"

def make_game(test: false)
  (PLAYER_RANGE).each do |num_players|
    if PENDING_USERS[num_players].length >= num_players
      users_for_game = []
      num_players.times { users_for_game << PENDING_USERS[num_players].shift }
      match = Match.new(users_for_game).tap { |match| match.game.deal }
      sleep 1 unless test
      match.users.each_with_index { |user, player_id| Pusher.trigger("waiting_for_players_channel_#{user.object_id}", 'send_to_game_event', { message: "#{match.object_id}/player/#{player_id}" }) }
    end
  end
end

make_game_thread = Thread.new {
  loop do
    sleep 0.1
    make_game
  end
  }

get '/' do
  @player_range = PLAYER_RANGE
  slim :index
end

get '/:match_id/player/:player_id' do
  match_id = params["match_id"].to_i
  player_id = params["player_id"].to_i
  @match = Match.find_by_obj_id(match_id) || Match.fake(match_id)
  @player = @match.players[player_id]
  @opponents = @match.opponents(@player) if @player
  slim :player
end

post '/start_game' do
  @user = User.new(name: params["name"])
  PENDING_USERS[params["num_players"].to_i] << @user
  slim :waiting_for_players
end
