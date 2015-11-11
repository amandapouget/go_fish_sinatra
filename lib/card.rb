class Card
  attr_reader :rank, :suit, :icon

  ICON_SOURCE_PATH = "/images/cards/"

  def initialize(rank:, suit:) # to assign defaults, use this syntax... rank: 'default string'
    @rank = rank
    @suit = suit
    @icon = set_icon
  end

  def rank_value
    card_values = ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace"]
    return card_values.index(@rank) + 2 if card_values.include?(@rank)
    return 0
  end

  def ==(another_card)
    eql?(another_card)
  end

  # the following two methods need tests
  def eql?(another_card)
    @rank == (another_card.rank) && @suit == (another_card.suit)
  end

  def hash
    rank.hash ^ suit.hash
  end

  def to_s
    "the " + @rank + " of " + @suit
  end

  def to_json(*args)
    { rank: rank, suit: suit }.to_json(*args)
  end

  def set_icon
    suit_letter = suit[0]
    ICON_SOURCE_PATH + "#{suit_letter}#{rank_value}.png"
  end
end
