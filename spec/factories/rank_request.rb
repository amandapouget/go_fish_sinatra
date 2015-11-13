FactoryGirl.define do
  factory :rank_request do
    rank { build(:card).rank }
    player { build(:player) }
    opponent { build(:player) }

    initialize_with { new(player, opponent, rank) }
  end
end
