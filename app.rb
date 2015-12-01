require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'pusher'
also_reload 'lib/**/*.rb'
Dir.glob('lib/**/*.rb') { |file| require_relative file }

# ActiveRecord::Base.add_observer MatchClientNotifier.instance

Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"
MyMatchMaker = MatchMaker.new

def match_maker
  MyMatchMaker
end

def start(match)
  match.game.deal
  match.save
end

get '/' do
  @player_range = PLAYER_RANGE
  slim :index
end

post '/wait' do
  @user = RealUser.create(name: params["name"])
  @num_players = params["num_players"].to_i
  match = match_maker.match(@user, @num_players)
  start(match) if match
  slim :waiting_for_players
end

post '/subscribed' do
  this_user = User.find(params["user_id"].to_i)
  match = this_user.matches.sort_by { |match| match.created_at }.last
  match.users.each { |user| Pusher.trigger("waiting_for_players_channel_#{user.id}", 'send_to_game_event', { message: "#{match.id}/player/#{user.id}" }) } if match
  return nil
end

post '/start_with_robots' do
  user = User.find(params["user_id"].to_i)
  num_players = params["num_players"].to_i
  match = match_maker.match(RobotUser.new, num_players) until match
  start(match)
  redirect "/#{match.id}/player/#{user.id}"
  return nil
end

get '/:match_id/player/:user_id.?:format?' do
  @match = Match.find_by_id(params["match_id"].to_i)
  @player = @match.players.find { |player| player.user_id == params["user_id"].to_i } if @match
  if @player
    params['format'] == 'json' ? @match.view(@player).to_json : slim(:player)
  else
    slim :no_player
  end
end

post '/card_request' do
  match = Match.find_by_id(params["matchId"].to_i)
  opponent = match.players.find { |player| player.user_id == params["opponentUserId"].to_i }
  player = match.players.find { |player| player.user_id == params["playerUserId"].to_i }
  match.run_play(player, opponent, params["rank"])
  return nil
end
