Dir.glob('lib/**/*.rb') { |file| require_relative file } # Is there a better way to require all the lib files?
#a
require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'pusher'
require 'pry'
also_reload 'lib/**/*.rb'

Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"
@@match_maker = MatchMaker.new

def start_game(match)
  match.users.each_with_index { |user, player_number| Pusher.trigger("waiting_for_players_channel_#{user.object_id}", 'send_to_game_event', { message: "#{match.object_id}/player/#{player_number}" }) }
  match.game.deal
  MatchClientNotifier.new(match)
end

def user
  @user ||= User.find(params["user_id"].to_i)
end

get '/' do
  @player_range = PLAYER_RANGE
  slim :index
end

post '/wait' do
  @user = User.new(name: params["name"])
  @num_players = params["num_players"].to_i
  @match = @@match_maker.match(@user, @num_players)
  if @match
    start_game(@match)
    @user.ready_to_play = true
    @player = @match.player(@user)
    @opponents = @match.opponents(@player)
    redirect "/#{@match.object_id}/player/#{@match.players.length - 1}"
  else
    slim :waiting_for_players
  end
end

post '/subscribed' do
  user.ready_to_play = true
  return nil
end

post '/start_with_robots' do
  num_players = params["num_players"].to_i
  user = user
  until @match do
    robot = RobotUser.new(2.5)
    @match = @@match_maker.match(robot, num_players)
  end
  start_game(@match)
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
