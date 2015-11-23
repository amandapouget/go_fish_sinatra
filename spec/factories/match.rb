FactoryGirl.define do
  factory :match do
    transient do
      num_players MIN_PLAYERS
      users { build_list(:user, num_players) }
    end
    initialize_with { new(users) }

    trait :dealt do
      after(:build) { |match| match.game.deal }
    end
  end
end
