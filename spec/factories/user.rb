FactoryGirl.define do
  factory :user do
    robot false
    client nil
    name { FAKENAMES.rotate![0] }
    initialize_with { new(name: name, client: client, robot: robot) }
  end
  factory :null_user do
  end
end
