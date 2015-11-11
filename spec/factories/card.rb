FactoryGirl.define do
  @ranks = ["two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace"]
  @suits = ["clubs", "diamonds", "hearts", "spades"]

  def rank_char(rank)
    if @ranks.include?(rank)
      index = @ranks.index(rank)
      return index + 2 if index < 9
      return rank[0]
    end
    return 0
  end

  factory :card do
    rank 'none'
    suit 'none'
    initialize_with { new(rank: rank, suit: suit) }
  end

  factory :random_card do
    initialize_with { new(rank: @ranks[rand(ranks.length)], suit: @suits[rand(suits.length)]) }
  end

  @ranks.each do |rank|
    @suits.each do |suit|
      card_name = "card_#{rank_char(rank)}#{suit[0]}"
      factory card_name.to_sym, class: Card do
        initialize_with { new(rank: rank, suit: suit) }
      end
    end
  end
end
