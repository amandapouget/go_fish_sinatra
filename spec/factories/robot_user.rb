FactoryGirl.define do
  factory :robot_user do
    initialize_with { new(0) }
  end
end
