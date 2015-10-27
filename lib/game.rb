require './lib/deck.rb'
require './lib/player.rb'
require 'pry'

class Game
  attr_accessor :players, :deck, :hand_size, :winner

  def initialize(players: [], hand_size: 5)
    raise ArgumentError, "Cannot have more than five players" if players.length > 5
    raise ArgumentError, "Hand size out of range" if (hand_size * players.length > 52 || hand_size < 1)
    @players = players
    @players = [Player.new, Player.new] if players.length < 2
    @deck = Deck.new(type: 'regular')
    @hand_size = hand_size
  end

  def deal
    @deck.shuffle
    hand_size.times { @players.each { |player| player.add_card(@deck.deal_next_card) } }
  end

  def winner
    return NullPlayer.new unless game_over?
    return player_with_most_books
  end

  # possibly remove the loser (ack loser)

  def player_with_most_books
    players_sorted = @players.clone # learned a bit about the importance of cloning here!
    players_sorted.sort_by { |player| player.books.length }
    players_sorted.reverse!
    return players_sorted[0] if players_sorted[0].books.length > players_sorted[1].books.length
    return NullPlayer.new
  end

  def go_fish(player)
    player.go_fish(deck)
  end

  def game_over?
    over = false
    @players.each { |player| over = true if player.out_of_cards? }
    over = true if @deck.empty?
    over
  end
end
