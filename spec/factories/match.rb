FactoryGirl.define do
  factory :match do
    transient do
      num_players MIN_PLAYERS
    end
    users { create_list(:real_user, num_players) }

    trait :dealt do
      after(:create) do |match|
        match.game.deal
        match.save
      end
    end
  end
end
