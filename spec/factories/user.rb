FactoryGirl.define do
  factory :real_user do
    client nil
    name { FAKENAMES.rotate![0] }
  end

  factory :null_user do
  end

  factory :robot_user do
    think_time 0
  end
end
