FactoryGirl.define do
  player_names = ["Amanda", "Bob", "Charlie", "David", "Echo", "Frank", "Gertrude", "Helga", "Iggy", "Jaqueline", "Kevin", "Lillian", "Marie"]

  factory :player do
    name player_names.rotate![0]
    initialize_with { new(name: name) }
  end
end
