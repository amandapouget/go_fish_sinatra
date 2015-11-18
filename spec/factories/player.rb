FactoryGirl.define do
  FAKENAMES = ["Marie", "Amanda", "Bob", "Charlie", "David", "Echo", "Frank", "Gertrude", "Helga", "Iggy", "Jaqueline", "Kevin", "Lillian"]

  factory :player do
    name { FAKENAMES.rotate![0] }
    robot false
    initialize_with { new(name: name, robot: robot) }
    transient { cards [] }

    after(:build) do |player, evaluator|
      evaluator.cards.each { |card| card.is_a?(Symbol) ? player.add_card(build(card)) : player.add_card(card) }
    end
  end

  factory :null_player do
  end
end
