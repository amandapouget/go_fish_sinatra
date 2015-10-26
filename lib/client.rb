require 'socket'
require 'json'
require 'pry'

class Client
  attr_reader :socket

  def start
    @socket = TCPSocket.open('localhost', 2000)
    # could put your JSON in here to load the welcome message and identifier given by accept in war_server
  end

  def puts_message
    begin
      message = @socket.read_nonblock(1000).chomp # Read lines from socket
      if message[0] == "{"
        interpret(message)
      else
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
      puts e.message
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

  def matchify(hash)
    player1 = hash.fetch("player1")
    player2 = hash.fetch("player2")
    player1_cards = hash.fetch("player1_cards")
    player2_cards = hash.fetch("player2_cards")
    player1_num_cards = hash.fetch("player1_num_cards")
    player2_num_cards = hash.fetch("player2_num_cards")
    player1_num_books = hash.fetch("player1_num_books")
    player2_num_books = hash.fetch("player2_num_books")
    player1_books = hash.fetch("player1_books")
    player2_books = hash.fetch("player2_books")
    deck_num_cards = hash.fetch("deck_num_cards")
    game_over = hash.fetch("game_over?")
    winner = hash.fetch("winner") || "tied"
    loser = hash.fetch("loser") || "tied"

    output = "Players: #{player1} and #{player2}. #{player1} has #{player1_num_books} books. #{player2} has #{player2_num_books} books. #{player1} has #{player1_num_cards} cards, including #{seriesify(player1_cards)}. #{player2} has #{player2_num_cards} cards, including #{seriesify(player2_cards)}. The deck has #{deck_num_cards} cards left to fish for."
    output += " Therefore, the game is over. Winner: #{winner}. Loser: #{loser}." if game_over
    puts output
  end

  def playerify(hash)
    player = hash.fetch("player")
    player_cards = hash.fetch("player_cards")
    player_num_cards = hash.fetch("player_num_cards")
    player_num_books = hash.fetch("player_num_books")
    game_over = hash.fetch("game_over?")

    output = "#{player}, you have #{player_num_cards} cards, including #{seriesify(player_cards)}. You have #{player_num_books} books."
    output += " The game is over!" if game_over
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
