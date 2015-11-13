FactoryGirl.define do
  factory :match do
    transient do
      num_players MIN_PLAYERS
    end
    initialize_with { new(build_list(:user, num_players)) }
  end
end
