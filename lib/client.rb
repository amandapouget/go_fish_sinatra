require 'socket'
require 'json'
require_relative './match.rb'

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
        message_ready = interpret(message)
        puts message_ready.chomp
      rescue
        puts message.chomp
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

  # the next three methods need rewriting

  def interpret(message)
    message_hash = JSON.parse(message)
    return matchify(message_hash) if message_hash.fetch("type") == "match_state"
    return playerify(message_hash) if message_hash.fetch("type") == "player_state"
    raise ArgumentError, "Not a match_state or player_state"
  end

  def matchify(message_hash)
    return "Game over but I can't tell you more because I need serialization! I can't even tell you if there are cards left to fish for."
    # match = message_hash.fetch("match")
    # players = match.players
    # player_names = []
    # match.players.each { |player| player_names << player.name }
    # player_names = seriesify(player_names)
    #
    # output = "Players: #{player_names}."
    # players.each { |player| output += " #{player.name} has #{player.books.size} books and #{player.count_cards} cards." }
    # output += " The deck has #{match.game.deck.count_cards} cards left to fish for."
    # output += " The game is over. Winner: #{winner}." if match.over
    # return output
  end

  def playerify(message_hash)
    # match = message_hash.fetch("match")
    # player_index = message_hash.fetch("player").to_i
    # player = match.players[player_index]
    # player_cards = []
    # player.cards.each { |card| player_cards << card.to_s }
    # output = "#{player.name}, you have #{player.count_cards} cards, including #{seriesify(player_cards)}. You have #{player.books.size} books."
    player_cards = message_hash.fetch("player_cards")
    output = "You have: #{seriesify(player_cards)}."
    return output
  end

  def seriesify(string_array)
    return "nothing" if string_array.size == 0
    return string_array[0] if string_array.size == 1
    if string_array.size == 2
      return string_array[0] + " and " + seriesify(string_array[1, string_array.size-1])
    elsif string_array.size > 2
      return string_array[0] + ", " + seriesify(string_array[1, string_array.size-1])
    end
  end
end
