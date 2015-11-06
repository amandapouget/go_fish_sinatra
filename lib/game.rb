require './lib/deck.rb'
require './lib/player.rb'
require 'pry'

MIN_PLAYERS = 2
MAX_PLAYERS = 5
PLAYER_RANGE = (MIN_PLAYERS..MAX_PLAYERS)

class Game
  attr_accessor :players, :deck, :hand_size, :winner, :requests, :next_turn

  def initialize(players: [], hand_size: 5)
    raise ArgumentError, "Cannot have more than #{MAX_PLAYERS} players" if players.length > MAX_PLAYERS
    @players = players
    @players = Array.new(MIN_PLAYERS) { Player.new } if players.length < MIN_PLAYERS
    @deck = Deck.new(type: 'regular')
    raise ArgumentError, "Hand size out of range" if (hand_size * players.length > @deck.count_cards || hand_size < 1)
    @hand_size = hand_size
    @requests = []
    @next_turn = @players[0]
  end

  def deal
    @deck.shuffle
    hand_size.times { @players.each { |player| player.add_card(@deck.deal_next_card) unless @deck.empty? } }
  end

  def winner
    return NullPlayer.new unless game_over?
    return player_with_most_books
  end

  def player_with_most_books
    players_sorted = @players.clone.tap { |new_players| (new_players.sort_by! { |player| player.books.length }).reverse! }
    return players_sorted[0] if players_sorted[0].books.length > players_sorted[1].books.length
    return NullPlayer.new
  end

  def go_fish(player, rank)
    fish_card = player.go_fish(deck)
    advance_turn unless fish_card.rank == rank
    fish_card
  end

  def make_request(player, opponent, rank)
    rank_request = RankRequest.new(player, opponent, rank)
    rank_request.execute
    @requests << rank_request
    rank_request
  end

  def advance_turn
    last_num = @players.index(@next_turn) + 1
    @next_turn = @players[last_num % @players.length]
  end

  def game_over?
    over = false
    @players.each { |player| over = true if player.out_of_cards? }
    over = true if @deck.empty?
    over
  end
end
