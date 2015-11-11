FactoryGirl.define do
  factory :deck do
    type 'none'
    initialize_with { new(type: type) }
  end
end

# a way to not have to duplicate the default above?
