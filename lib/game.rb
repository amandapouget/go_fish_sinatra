require_relative 'player'
require_relative 'card'
require_relative 'rank_request'

MIN_PLAYERS = 2
MAX_PLAYERS = 5
PLAYER_RANGE = (MIN_PLAYERS..MAX_PLAYERS)

class Game
  attr_accessor :players, :deck, :hand_size, :winner, :requests, :next_turn

  def initialize(players: [], hand_size: 5)
    @players = players.size >= MIN_PLAYERS ? players : Array.new(MIN_PLAYERS) { Player.new }
    @deck = Card.deck
    @hand_size = hand_size
    @requests = []
    @next_turn = @players[0]
    raise ArgumentError, "Cannot have more than #{MAX_PLAYERS} players" if players.size > MAX_PLAYERS
    raise ArgumentError, "Hand size out of range" if (hand_size * players.size > @deck.count_cards || hand_size < 1)
  end

  def deal
    @deck.shuffle
    hand_size.times { @players.each { |player| player.add_card(@deck.deal_next_card) unless @deck.empty? } }
  end

  def winner
    game_over? ? player_with_most_books : NullPlayer.new
  end

  def player_with_most_books
    players_sorted = @players.clone.tap { |new_players| (new_players.sort_by! { |player| player.books.size }).reverse! }
    return players_sorted[0] if players_sorted[0].books.size > players_sorted[1].books.size
    return NullPlayer.new
  end

  def go_fish(player, rank)
    fish_card = player.go_fish(deck)
    advance_turn unless fish_card.rank == rank
    fish_card
  end

  def make_request(player, opponent, rank)
    @requests << RankRequest.new(player, opponent, rank).tap { |rank_request| rank_request.execute }
    @requests.last
  end

  def advance_turn
    next_player_index = @players.index { |player| player.user_id == @next_turn.user_id } + 1
    @next_turn = @players[next_player_index % @players.size]
  end

  def game_over?
    @deck.empty? || @players.any? { |player| player.out_of_cards? }
  end
end
