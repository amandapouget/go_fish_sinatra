module FreshGameCreate
  include Spinach::DSL

  def reset_pending
    PENDING_USERS.each_key { |num_players| PENDING_USERS[num_players] = [] }
  end

  def reset_matches
    Match.clear
  end

  def fill_form(name, num_players)
    visit '/'
    fill_in 'name', :with => name
    choose(num_players)
  end

  def add_player(num_players)
    fill_form("Anonymous", num_players)
    click_button 'Start Game'
  end

  def start_three_game(name) # for factory
    names = ["Bob", "Charlie", "David", "Echo"]
    match = Match.new([User.new(name: name), User.new(name: names[rand(3)]), User.new(name: names[rand(3)])])
    match.game.deal
    match
  end
end
