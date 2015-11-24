FactoryGirl.define do
  factory :user do
    client nil
    name { FAKENAMES.rotate![0] }
  end
  factory :null_user do
  end
end
