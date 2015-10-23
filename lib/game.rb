require './lib/deck.rb'
require './lib/player.rb'

class Game
  attr_accessor :player1, :player2, :deck, :winner, :loser

  def initialize(player1: Player.new, player2: Player.new)
    @player1 = player1
    @player2 = player2
    @deck = Deck.new(type: 'regular')
    @winner = NullPlayer.new
    @loser = NullPlayer.new
  end

  def deal
    deck.shuffle
    5.times do
      player1.add_card(deck.deal_next_card)
      player2.add_card(deck.deal_next_card)
    end
  end

  def winner
    @winner = player1 if player1.books.length > player2.books.length
    @winner = player2 if player1.books.length < player2.books.length
    @winner
  end

  def loser
    @loser = player2 if player1.books.length > player2.books.length
    @loser = player1 if player1.books.length < player2.books.length
    @loser
  end

  def game_over?
    player1.out_of_cards? || player2.out_of_cards? || deck.empty?
  end
end
