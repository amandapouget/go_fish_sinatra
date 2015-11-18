Dir.glob('lib/**/*.rb') { |file| require_relative file } # Is there a better way to require all the lib files?
require 'slim'
require 'sinatra'
require 'sinatra/reloader'
require 'pusher'
require 'pry'
also_reload 'lib/**/*.rb'

PENDING_USERS = {}.tap { |pending_users| (PLAYER_RANGE).each { |num_players| pending_users[num_players] = [] } }
Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"
@@match_maker = MatchMaker.new

def make_game(num_players, user_wants_robots: nil)
  users = user_wants_robots ? user_and_robots(user_wants_robots, num_players) : real_players(num_players)
  start_game(Match.new(users).tap { |match| match.game.deal }) if users
end

def user_and_robots(user, num_players)
  PENDING_USERS[num_players].delete(user)
  [user].concat(Array.new(num_players - 1) { User.new(robot: true) })
end

def real_players(num_players)
  PENDING_USERS[num_players].slice!(0, num_players)
end

def start_game(match)
  match.users.each_with_index { |user, player_id| Pusher.trigger("waiting_for_players_channel_#{user.object_id}", 'send_to_game_event', { message: "#{match.object_id}/player/#{player_id}" }) }
end

def run_plays(match, player, opponent, rank)
  return if match.over
  match.run_play(player, opponent, rank)
  Pusher.trigger("game_play_channel_#{match.object_id}", 'refresh_event', { message: "reload page" } )
  next_player = match.game.next_turn
  next_player.robot ? sleep(2.5) : return
  run_plays(match, next_player, match.opponents(next_player).sample, next_player.cards.sample.rank)
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

post '/subscribed' do
  num_players = params["num_players"].to_i
  make_game(num_players) if PENDING_USERS[num_players].size >= num_players
  return nil
end

post '/start_with_robots' do
  num_players = params["num_players"].to_i
  user = User.find(params["user_id"].to_i, PENDING_USERS[num_players])
  make_game(num_players, user_wants_robots: user)
  return nil
end

get '/:match_id/player/:user_id.?:format?' do
  @match = Match.find(params["match_id"].to_i)
  @player = @match.players[params["user_id"].to_i] if @match
  @opponents = @match.opponents(@player) if @player
  params['format'] == 'json' ? @match.view(@player).to_json : slim(:player)
end

post '/:match_id/card_request' do
  match = Match.find(params["match_id"].to_i)
  opponent = match.player_from_id(params["opponent_object_id"].to_i)
  player = match.player_from_id(params["player_object_id"].to_i)
  run_plays(match, player, opponent, params["rank"]) if match.game.next_turn == player
  return nil
end
