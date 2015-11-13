FactoryGirl.define do
  factory :deck do
    trait :with_cards do
      initialize_with { Card.deck }
    end

    trait :empty do
      initialize_with { new() }
    end

    after(:build) do |deck, evaluator|
      deck.cards.map! { |card| card.is_a?(Symbol) ? build(card) : card }
    end
  end
end
