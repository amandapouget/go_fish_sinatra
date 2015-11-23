require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'pusher'
also_reload 'lib/**/*.rb'
Dir.glob('lib/**/*.rb') { |file| require_relative file }

Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"

def match_maker
  @@match_maker ||= MatchMaker.new
end

get '/' do
  @player_range = PLAYER_RANGE
  slim :index
end

post '/wait' do
  @user = User.new(name: params["name"])
  @num_players = params["num_players"].to_i
  match = match_maker.match(@user, @num_players)
  match.game.deal if match
  slim :waiting_for_players
end

post '/subscribed' do
  user = User.find(params["user_id"].to_i)
  match = Match.all.find { |match| match.users.include? user }
  Pusher.trigger("waiting_for_players_channel_#{user.object_id}", 'send_to_game_event', { message: "#{match.object_id}/player/#{match.users.index(user)}" }) if match
  return nil
end

post '/start_with_robots' do # broken because need to put the pusher back in matchclient or else it tries to play with robots before being subscribed AGAIN with the pusher issue :-(!!
  user = User.find(params["user_id"].to_i)
  num_players = params["num_players"].to_i
  until @match
    @match = match_maker.match(RobotUser.new, num_players)
  end
  @match.game.deal
  Pusher.trigger("waiting_for_players_channel_#{user.object_id}", 'send_to_game_event', { message: "#{@match.object_id}/player/#{@match.users.index(user)}" })
  return nil
end

get '/:match_id/player/:player_num.?:format?' do
  @match = Match.find(params["match_id"].to_i)
  @player = @match.players[params["player_num"].to_i] if @match
  @opponents = @match.opponents(@player) if @player
  params['format'] == 'json' ? @match.view(@player).to_json : slim(:player)
end

post '/:match_id/card_request' do
  match = Match.find(params["match_id"].to_i)
  opponent = match.player_from_id(params["opponent_object_id"].to_i)
  player = match.player_from_id(params["player_object_id"].to_i)
  match.run_play(player, opponent, params["rank"]) if match.game.next_turn == player
  return nil
end
