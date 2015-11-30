require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'pusher'
require 'pry'
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
  MatchClientNotifier.new(match)
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
  match = Match.all.find { |match| match.users.include? this_user }
  match.users.each { |user| Pusher.trigger("waiting_for_players_channel_#{user.id}", 'send_to_game_event', { message: "#{match.id}/player/#{match.users.index(user)}" }) } if match
  return nil
end

post '/start_with_robots' do
  user = User.find(params["user_id"].to_i)
  num_players = params["num_players"].to_i
  until @match
    @match = match_maker.match(RobotUser.new, num_players)
  end
  start(@match)
  Pusher.trigger("waiting_for_players_channel_#{user.id}", 'send_to_game_event', { message: "#{@match.id}/player/#{@match.users.index(user)}" })
  return nil
end

get '/:match_id/player/:player_index.?:format?' do
  @match = Match.find_by_id(params["match_id"].to_i)
  @player = @match.players[params["player_index"].to_i] if @match
  @opponents = @match.opponents(@player) if @player
  params['format'] == 'json' ? @match.view(@player).to_json : slim(:player)
end

post '/:match_id/card_request' do
  match = Match.find_by_id(params["match_id"].to_i)
  opponent = match.players[params["opponent_index"].to_i]
  player = match.players[params["player_index"].to_i]
  if match.game.next_turn == player
    match.run_play(player, opponent, params["rank"])
    match.save
  end
  return nil
end
