require 'socket'
require 'json'
require './lib/match.rb'

class Client
  attr_reader :socket

  def start
    @socket = TCPSocket.open('localhost', 2000)
    # could put your JSON in here to load the welcome message and identifier given by accept in war_server
  end

  def puts_message
    begin
      message = @socket.read_nonblock(1000).chomp # Read lines from socket
      begin
        interpret(message)
      rescue
        puts message
      end
    rescue IO::WaitReadable
    end
  end

  def give_input_when_asked
    begin
      input = ($stdin.read_nonblock(1000)).chomp
      provide_input(input)
    rescue => e
    end
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def interpret(message)
    message_hash = JSON.parse(message)
    matchify(message_hash) if message_hash.fetch("type") == "match_state"
    playerify(message_hash) if message_hash.fetch("type") == "player_state"
  end

  def matchify(message_hash)
    match_id = message_hash.fetch("match") # can't get it to parse / inflate!!!
    match = Match.find_by_obj_id(match_id) # cheating... how would the client have access to all Match info...
    players = match.players
    player_names = []
    match.players.each { |player| player_names << player.name }
    player_names = seriesify(player_names)

    output = "Players: #{player_names}."
    players.each { |player| output += " #{player.name} has #{player.books.length} books and #{player.count_cards} cards." }
    output += " The deck has #{match.game.deck.count_cards} cards left to fish for."
    output += " The game is over. Winner: #{winner}." if match.over
    puts output
  end

  def playerify(message_hash)
    match_id = message_hash.fetch("match") # can't get it to parse / inflate!!!
    match = Match.find_by_obj_id(match_id) # cheating... how would the client have access to all Match info...
    player_index = message_hash.fetch("player").to_i
    player = match.players[player_index]
    player_cards = []
    player.cards.each { |card| player_cards << card.to_s }
    player = match.players[player_index]

    output = "#{player.name}, you have #{player.count_cards} cards, including #{seriesify(player_cards)}. You have #{player.books.length} books."
    output += " The game is over!" if match.over
    puts output
  end

  def seriesify(string_array)
    return "nothing" if string_array.length == 0
    return string_array[0] if string_array.length == 1
    if string_array.length == 2
      return string_array[0] + " and " + seriesify(string_array[1, string_array.length-1])
    elsif string_array.length > 2
      return string_array[0] + ", " + seriesify(string_array[1, string_array.length-1])
    end
  end
end
