require 'socket'
require 'json'
require_relative './game'
require_relative './player'
require_relative './user.rb'
require 'pry'
require 'timeout'

class Server
  attr_accessor :port, :socket, :pending_users, :clients, :game
  WELCOME = "Welcome to go fish! I will connect you with your partner..."
  ENTER_ID = "Please enter your unique id or hit enter to create a new user."
  ASK_NAME = "What is your name?"
  START_GAME = "Hit enter to play!"
  RANK_REQUEST = "What rank would you like to ask for? (Enter as a word.)"
  OPPONENT_REQUEST = "What player would you like to ask?"
  GO_FISH = "Hit enter to go fish!"
  FORFEIT = "Game forfeited!"
  MIN_PLAYERS = 2
  MAX_PLAYERS = 5
  HAND_SIZE = 5

  def initialize(port: 2000)
    @port = port
  end

  def start
    @socket = TCPServer.open('localhost', @port)
    @pending_users = []
    @clients = []
  end

  def make_threads # not tested
    until @socket.closed? do
      Thread.start(accept) { |client| run(client) }
    end
  end

  def accept
    client = @socket.accept
    @clients << client
    send_output(client, WELCOME)
    client
  end

  def run(client) # NOT TESTED
    add_user(client)
    sleep 1 # gives it one second to allow more players to connect; so game defaults to MIN_PLAYERS users but could welcome up to MAX_PLAYERS if connect volume is high enough...
    if enough_players?
      users_to_play = []
      MAX_PLAYERS.times { users_to_play << @pending_users.shift unless @pending_users.empty? }
      match = make_match(users_to_play)
      ask_to_start_match(match)
      match.game.deal
      play_match(match)
      match.users.each { |user| stop_connection(user.client) }
    end
  end

  def add_user(client, id = nil) # had to add the optional argument just to make testable
    user = match_user(client, id || get_id(client))
    @pending_users << user unless user.match_in_progress?
  end

  def enough_players?
    @pending_users.length >= MIN_PLAYERS
  end

  def get_id(client)
    send_output(client, ENTER_ID)
    get_input(client).to_i || die(client)
  end

  def get_name(client)
    send_output(client, ASK_NAME)
    get_input(client) || die(client) # add time-out for unresponsive user?
  end

  def get_input(client)
    begin
      sleep 0.0001
      client.read_nonblock(1000).strip
    rescue IO::WaitReadable
      retry
    rescue IOError
      return nil
    end
  end

  def send_output(client, output)
    client.puts(output)
  rescue IOError
  end

  def die(client) # NOT TESTED
    stop_connection(client)
    Thread.kill(Thread.current)
  end

  def match_user(client, id)
    user = User.find(id)
    if user
      send_output(client, "Welcome back #{user.name}!")
    else
      user = User.new(name: get_name(client))
      send_output(client, "Welcome, #{user.name}! Your unique id is #{user.object_id}. Don't lose it! You'll need it to log in again as you play.")
    end
    user.client = client
    user
  end

  def ask_to_start_match(match)
    match.users.each { |user| send_output(user.client, START_GAME) }
    match.users.each { |user| get_input(user.client) }
  end

  def make_match(users)
    Match.new(users, hand_size: HAND_SIZE)
  end

  def play_match(match, timeout_sec = 30) # need to tell the players who they are playing
    while !match.game.game_over?
      match.users.each { |user| play_move(match, user, timeout_sec) unless match.game.game_over? }
    end
    tell_match(match)
    match.end_match
  end

  def play_move(match, user, timeout_sec = 30) # NOT TESTED
    tell_player(match, user)
    rank = get_rank(match, user, timeout_sec)
    opponent = get_opponent(match, user, timeout_sec)
    match.users.each { |user| tell_request(rank, user, opponent) }
    unless opponent.is_a? NullPlayer
      send_output(opponent.client, "Do you have any #{rank}s?")
      get_input_or_end_match(match, opponent, timeout_sec)
    end
    winnings = player.request_cards(match.player(opponent), rank)
    if winnings.length > 0
      tell_winnings(match, user, winnings)
    else
      play_fish(match, user, timeout_sec)
      match.users.each { |user| tell_fish(match, user) }
    end
  end

  def get_rank(match, user, timeout_sec = 30)
    send_output(user.client, RANK_REQUEST)
    get_input_or_end_match(match, user, timeout_sec)
  end

  def get_opponent(match, user, timeout_sec = 30)
    send_output(user.client, OPPONENT_REQUEST)
    player_name = get_input_or_end_match(match, user, timeout_sec)
    player = match.player_from_name(player_name)
    return match.user(player)
  end

  def play_fish(match, user, timeout_sec = 30)
    player = match.player(user)
    send_output(user.client, GO_FISH)
    get_input_or_end_match(match, user, timeout_sec)
    card_drawn = match.game.go_fish(match.player(user)).to_s
    send_output(user.client, "You drew #{card_drawn}.")
    tell_player(match, user)
  end

  def get_input_or_end_match(match, user, timeout_sec) # not currently used
    input = nil
    begin
      Timeout::timeout(timeout_sec) { input = get_input(user.client) until input }
    rescue
      match.users.each do |user|
        send_output(user.client, FORFEIT)
        stop_connection(user.client)
      end
      match.end_match
      Thread.kill(Thread.current) unless timeout_sec == 0.001 # moment of cheating... can't have it kill RSPEC thread!
    end
    input if input
  end

  def tell_fish(match, user_playing)
    match.users.each { |user| send_output(user.client, "#{user_playing.name} went fish!") }
  end

  def tell_request(match, rank, user_playing, opponent)
    match.users.each { |user| send_output(user.client, "#{user_playing.name} requested every two in #{opponent.name}'s hand!") }
  end

  def tell_winnings(match, user, winnings)
    send_output(user.client, "You received:")
    winnings.each { |card| send_output(user.client, card.to_s) }
  end

  def tell_player(match, user)
    player_info = JSON.dump(match.json_ready(user))
    send_output(user.client, player_info)
  end

  def tell_match(match)
    match_info = JSON.dump(match.json_ready)
    match.users.each { |user| send_output(user.client, match_info) }
  end

  def stop_connection(client)
    client.close unless client.closed?
    @clients.delete(client)
  end

  def stop_server
    connections = []
    @clients.each { |client| connections << client } if @clients
    connections.each { |client| stop_connection(client) }
    @pending_users = [] if @pending_users
    @socket.close if (@socket && !@socket.closed?)
  end
end
