FactoryGirl.define do
  factory :player do
    name { User::FAKENAMES.rotate![0] }
    user_id nil
    transient { cards { [] } }

    after(:build) do |player, evaluator|
      evaluator.cards.each { |card| card.is_a?(Symbol) ? player.add_card(build(card)) : player.add_card(card) }
    end
  end

  factory :null_player do
  end
end
