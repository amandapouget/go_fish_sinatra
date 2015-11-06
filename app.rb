Dir.glob('lib/**/*.rb') { |file| require_relative file } # Is there a better way to require all the lib files?
require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'pusher'
also_reload 'lib/*.rb'

PENDING_USERS = {}.tap { |pending_users| (PLAYER_RANGE).each { |num_players| pending_users[num_players] = [] } }
Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"

def make_game(user_id, num_players)
  if PENDING_USERS[num_players].length >= num_players
    users_for_game = PENDING_USERS[num_players]
    PENDING_USERS[num_players] = []
    return Match.new(users_for_game).tap { |match| match.game.deal }
  end
end

def start_game(match)
  match.users.each_with_index do |user, player_id|
    Pusher.trigger("waiting_for_players_channel_#{user.object_id}", 'send_to_game_event', { message: "#{match.object_id}/player/#{player_id}" })
  end
end

get '/' do
  @player_range = PLAYER_RANGE
  slim :index
end

post '/wait' do
  @user = User.new(name: params["name"])
  @num_players = params["num_players"].to_i
  PENDING_USERS[@num_players] << @user
  slim :waiting_for_players
end

post '/subscribed' do # this post tells the server when the 'wait' page has loaded!
  user_id = params["user_id"].to_i
  num_players = params["num_players"].to_i
  match = make_game(user_id, num_players)
  start_game(match) if match
  return nil # spent a really long time on this bug :-( (and yes did try to submit hidden html form but that caused a page reload... thus defeating the purpose of this post!)
end

get '/:match_id/player/:player_id' do
  match_id = params["match_id"].to_i
  player_id = params["player_id"].to_i
  @match = Match.find_by_obj_id(match_id) || Match.fake(match_id)
  @player = @match.players[player_id]
  @opponents = @match.opponents(@player) if @player
  slim :player
end

post '/:match_id/card_request' do
  match = Match.find_by_obj_id(params["match_id"].to_i) || Match.all[0]
  unless match.over
    opponent = match.player_from_object_id(params["opponent_object_id"].to_i)
    player = match.player_from_object_id(params["player_object_id"].to_i)
    rank = params["rank"]
    if match.game.next_turn == player
      match.run_play(player, opponent, rank)
      Pusher.trigger("game_play_channel_#{match.object_id}", 'refresh_event', { message: "reload page" } )
    end
  end
end
