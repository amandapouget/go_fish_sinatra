require 'socket'
require_relative 'game'
require_relative 'player'
require_relative 'user'
require_relative 'match'

class Server
  attr_accessor :port, :socket, :pending_users, :clients, :game
  WELCOME = "Welcome to go fish! I will connect you with your partner..."
  ENTER_ID = "Please enter your unique id or hit enter to create a new user."
  ASK_NAME = "What is your name?"
  RANK_REQUEST = "What rank would you like to ask for? (Enter as a word.)"
  OPPONENT_REQUEST = "What player would you like to ask?"
  GO_FISH = "Hit enter to go fish!"
  FORFEIT = "Game forfeited!"
  MIN_PLAYERS = 2
  MAX_PLAYERS = 5
  HAND_SIZE = 5

  def initialize(port: 2000)
    @port = port
    @pending_users = []
    @clients = []
  end

  def start
    @socket = TCPServer.open('localhost', @port)
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
      match.game.deal
      play_match(match)
      match.users.each { |user| stop_connection(user.client) }
    end
  end

  def add_user(client, id = nil) # had to add the optional argument just to make testable
    user = match_user(client, id || get_info(client, ENTER_ID).to_i)
    @pending_users << user unless user.current_match
  end

  def enough_players?
    @pending_users.size >= MIN_PLAYERS
  end

  def get_info(client, message, delay=0.001)
    send_output(client, message)
    get_input(client, delay) || die(client) # add time-out for unresponsive user?
  end

  def get_input(client, delay=0.001)
    begin
      sleep delay
      client.read_nonblock(1000).strip
    rescue IO::WaitReadable
      retry
    rescue => e
      return nil
    end
  end

  def send_output(client, output)
    begin
      client.print(output)
      sleep 0.001
    rescue IOError => e
      puts e.message
    end
  end

  def die(client) # NOT TESTED
    stop_connection(client)
    Thread.kill(Thread.current)
  end

  def match_user(client, id)
    user = User.find_by(id: id)
    if user
      send_output(client, "Welcome back #{user.name}!")
    else
      user = User.create(name: get_info(client, ASK_NAME))
      send_output(client, "Welcome, #{user.name}! Your unique id is #{user.object_id}. Don't lose it! You'll need it to log in again as you play.")
    end
    user.client = client
    user
  end

  def make_match(users)
    Match.new(users, hand_size: HAND_SIZE)
  end

  def play_match(match) # need to tell the players who they are playing
    while !match.game.game_over?
      match.users.each { |user| play_move(match, user) unless match.game.game_over? }
    end
    tell_match(match)
    match.end_match
  end

  def play_move(match, user) # NOT TESTED
    tell_player_his_view(match, user)
    rank = get_rank(match, user)
    opponent = get_opponent(match, user)
    tell_request(match, rank, user, opponent)
    unless opponent.is_a? NullUser
      tell_player_his_hand(match, opponent)
      send_output(opponent.client, "Do you have any #{rank}s?")
      get_input(opponent.client)
      winnings = match.player(user).request_cards(match.player(opponent), rank)
    end
    if winnings && winnings.size > 0
      tell_winnings(match, user, winnings)
    else
      play_fish(match, user, rank)
      tell_fish(match, user)
    end
  end

  def get_rank(match, user)
    send_output(user.client, RANK_REQUEST)
    get_input(user.client)
  end

  def get_opponent(match, user)
    send_output(user.client, OPPONENT_REQUEST)
    player_name = ""
    while player_name == "" do
      player_name = get_input(user.client)
    end
    player = match.player_from_name(player_name)
    return match.user(player)
  end

  def play_fish(match, user, rank)
    player = match.player(user)
    send_output(user.client, GO_FISH)
    get_input(user.client)
    card_drawn = match.game.go_fish(match.player(user), rank).to_s
    send_output(user.client, "You drew #{card_drawn}.")
  end

  def tell_fish(match, user_playing)
    match.users.each { |user| send_output(user.client, "#{user_playing.name} went fish!") }
  end

  def tell_request(match, rank, user_playing, opponent)
    match.users.each { |user| send_output(user.client, "#{user_playing.name} requested every #{rank} in #{opponent.name}'s hand!") }
  end

  def tell_winnings(match, user, winnings)
    send_output(user.client, "You received:")
    winnings.each { |card| send_output(user.client, card.to_s) }
  end

  def tell_player_his_view(match, user)
    player_info = match.view(match.player(user))
    send_output(user.client, player_info)
  end

  def tell_match(match)
    match.users.each { |user| tell_player_his_view(match, user) }
  end

  def stop_connection(client)
    client.close unless client.closed?
    @clients.delete(client)
  end

  def stop
    @clients.clone.each { |client| stop_connection(client) }
    @pending_users = []
    @socket.close if (@socket && !@socket.closed?)
  end
end
