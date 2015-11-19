FactoryGirl.define do
  factory :match do
    transient do
      num_players MIN_PLAYERS
      users { build_list(:user, num_players) }
    end
    initialize_with { new(users) }

    trait :one_user_plus_robots do
      transient do
        users {
          user = build(:user)
          robots = build_list(:user, (num_players - 1), robot: true)
          [user].concat(robots)
        }
      end
    end

    trait :dealt do
      after(:build) { |match| match.game.deal }
    end
  end
end
