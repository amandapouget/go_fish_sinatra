require_relative 'card'

class Deck
  attr_accessor :cards, :type

  def initialize(cards = [])
    @cards = cards
  end

  def shuffle
    @cards.shuffle!
  end

  def count_cards
    @cards.size
  end

  def deal_next_card
    @cards.shift
  end

  def empty?
    count_cards == 0
  end

  def to_json(*args)
    { cards: cards }.to_json
  end
end
