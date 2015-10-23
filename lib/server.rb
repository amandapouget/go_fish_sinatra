require 'socket'
require 'json'
require_relative './game'
require_relative './player'
require './lib/user.rb'
require 'pry'
require 'timeout'

class Server
  attr_accessor :port, :socket, :pending_users, :clients, :game
  WELCOME = "Welcome to go fish! I will connect you with your partner..."
  ENTER_ID = "Please enter your unique id or hit enter to create a new user."
  ASK_NAME = "What is your name?"
  START = "Hit enter to play!"
  RANK_REQUEST = "What rank would you like to ask for? (Enter as a word.)"
  OPPONENT_REQUEST = "What player would you like to ask?"
  GO_FISH = "Hit enter to go fish!"
  FORFEIT = "Game forfeited!"


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
    user = match_user(client, get_id(client))
    @pending_users << user unless user.match_in_progress?
    if player_pair_ready?
      opponent = @pending_users.shift
      user = @pending_users.shift
      match = make_match(user, opponent)
      ask_to_start_match(match)
      match.game.deal
      play_match(match)
      match.users.each { |user| stop_connection(user.client) }
    end
  end

  def player_pair_ready?
    @pending_users.length >= 2
  end

  def get_id(client)
    send_output(client, ENTER_ID)
    get_input(client).to_i || die
  end

  def get_name(client)
    send_output(client, ASK_NAME)
    get_input(client) || die # add time-out for unresponsive user?
  end

  def get_input(client)
    begin
      client.read_nonblock(1000).chomp
    rescue IO::WaitReadable
      IO.select([client])
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
      send_output(client, "Your unique id is #{user.object_id}. Don't lose it! You'll need it to log in again as you play.")
    end
    user.client = client
    user
  end

  def ask_to_start_match(match)
    match.users.each { |user| send_output(user.client, START) }
    match.users.each { |user| get_input_or_end_match(match, user, 30) }
  end

  def make_match(user1, user2)
    player1 = Player.new(name: user1.name)
    player2 = Player.new(name: user2.name)
    game = Game.new(player1: player1, player2: player2)
    match = Match.new(game: game, user1: user1, user2: user2)
    match
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
    player = match.player(user)
    rank = get_rank(match, user, timeout_sec)
    puts "GOT RANK"
    opponent = match.opponent(user) # user get_opponent(match, user, timeout_sec) with multiple opponents
    puts "GOT OPPONENT"
    unless opponent.is_a? NullPlayer
      opponent_user = match.user(opponent)
      send_output(opponent_user.client, "Do you have any #{rank}s?")
      get_input_or_end_match(match, opponent_user, timeout_sec)
    end
    winnings = player.request_cards(opponent, rank)
    if winnings.length > 0
      tell_winnings(match, user, winnings)
      puts "TOLD WINNINGS"
    else
      play_fish(match, user, timeout_sec)
      puts "PLAYED FISH"
      puts "CARDS IN DECK #{match.game.deck.count_cards}"
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
  end

  def play_fish(match, user, timeout_sec = 30)
    player = match.player(user)
    send_output(user.client, GO_FISH)
    get_input_or_end_match(match, user, timeout_sec)
    card_drawn = match.game.go_fish(match.player(user)).to_s
    send_output(user.client, "You drew #{card_drawn}.")
    tell_player(match, user)
  end

  def get_input_or_end_match(match, user, timeout_sec)
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

  def tell_winnings(match, user, winnings)
    send_output(user.client, "You received:")
    winnings.each { |card| send_output(user.client, card.to_s) }
  end

  def tell_player(match, user)
    player_info = JSON.dump(match.to_json(user))
    send_output(user.client, player_info)
  end

  def tell_match(match)
    match_info = JSON.dump(match.to_json)
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
