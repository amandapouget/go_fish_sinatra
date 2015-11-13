FactoryGirl.define do
  def rank_char(rank)
    if Card::RANKS.include?(rank)
      index = Card::RANKS.index(rank)
      return index + 2 if index < 9
      return rank[0]
    end
    return 0
  end

  factory :card do
    rank { Card::RANKS[rand(Card::RANKS.length)] }
    suit { Card::SUITS[rand(Card::SUITS.length)] }
    initialize_with { new(rank: rank, suit: suit) }
  end

  Card::RANKS.each do |rank|
    Card::SUITS.each do |suit|
      card_name = "card_#{rank_char(rank)}#{suit[0]}"
      factory card_name.to_sym, class: Card do
        initialize_with { new(rank: rank, suit: suit) }
      end
    end
  end
end
