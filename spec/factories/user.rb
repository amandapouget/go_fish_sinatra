FactoryGirl.define do
  factory :user do
    client nil
    name { FAKENAMES.rotate![0] }
    initialize_with { new(name: name, client: client) }
  end
  factory :null_user do
  end
end
