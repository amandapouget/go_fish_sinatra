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
    rank { Card::RANKS[rand(Card::RANKS.size)] }
    suit { Card::SUITS[rand(Card::SUITS.size)] }
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

FactoryGirl.define do
  factory :book, class: Array do
    after(:build) do |book|
      book = [build(:card_ad), build(:card_as), build(:card_ah), build(:card_ac)]
    end
  end
end
