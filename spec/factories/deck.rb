FactoryGirl.define do
  factory :deck do
    type 'none'
    initialize_with { new(type: type) }
  end
end
