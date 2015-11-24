require_relative 'deck'

class Card
  attr_reader :rank, :suit, :icon

  ICON_SOURCE_PATH = "/images/cards/"
  RANKS = ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace"]
  SUITS = ["clubs", "diamonds", "hearts", "spades"]

  def initialize(rank:, suit:)
    @rank = rank
    @suit = suit
    @icon = set_icon
  end

  def self.deck
    cards = RANKS.map { |rank| SUITS.map { |suit| Card.new(rank: rank, suit: suit) } }.flatten
    Deck.new(cards)
  end

  def rank_value
    return RANKS.index(@rank) + 2 if RANKS.include?(@rank)
    return 0
  end

  def eql?(another_card)
    @rank == (another_card.rank) && @suit == (another_card.suit)
  end

  alias == eql?

  def hash
    rank.hash ^ suit.hash
  end

  def to_s
    "the " + @rank + " of " + @suit
  end

  def set_icon
    "#{ICON_SOURCE_PATH}#{suit[0]}#{rank_value}.png" if rank_value > 1 && SUITS.include?(suit)
  end
end
