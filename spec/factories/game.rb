FactoryGirl.define do
  factory :game do
    transient do
      num_players MIN_PLAYERS
    end

    initialize_with { new(players: build_list(:player, num_players)) }
  end
end
