require 'rack/test'
require './app.rb'

module FreshGameCreate
  include Spinach::DSL

  def reset
    match_maker.pending_users.each_key { |num_players| match_maker.pending_users[num_players] = [] }
    Match.destroy_all
  end

  def fill_form(name, num_players)
    visit '/'
    fill_in 'name', :with => name
    choose(num_players)
    click_button 'Start Game'
  end

  def add_player(num_players)
    fill_form("New Player Who Joined", num_players)
  end

  def visit_player_page
    visit "/#{@my_match.id}/player/#{me_player.user_id}"
    expect_page_ready
  end

  def expect_page_ready
    expect(page).to have_selector '#ready'
  end

  def expect_page_has_cards(cards, expect_true = true)
    cards.each { |card| expect(page.has_selector?("img[src = '#{card.icon}']")) } if expect_true
    cards.each { |card| expect(page.has_no_selector?("img[src = '#{card.icon}']")) } unless expect_true
  end

  def current_cards_icons
    find_all('.your-cards').to_a.map! { |card| card = card['src'] }
  end

  def game_with_three_players_each_has_one_ace
    reset
    start_three_game(users: 3, robots: 0)
    @my_match.players.each { |player| player.cards = [build(:card_as)] }
    @my_match.players.each { |player| expect(player.cards).to eq [build(:card_as)] }
  end

  def game_with_one_user_two_robots_each_has_one_different_card
    reset
    start_three_game(users: 1, robots: 2)
    cards = [build(:card_as), build(:card_ks), build(:card_qs)]
    @my_match.players.each_with_index { |player, index| player.cards = [cards[index]] }
    @my_match.players.each do |player|
      expect(player.cards.length).to eq 1
      cards.reject! { |card| card == player.cards[0] }
    end
    expect(cards).to eq []
  end

  def start_three_game(users:, robots:)
    @num_players = 3
    users.times { @my_match = match_maker.match(create(:real_user), 3) }
    robots.times { @my_match = match_maker.match(create(:robot_user), 3) } until @my_match
    @my_match.save
    expect(Match.find(@my_match.id)).to eq @my_match
  end

  def me_player; @my_match.players.find { |player| player.is_a? Player }; end
  def first_opponent; @my_match.opponents(me_player)[0]; end
  def second_opponent; @my_match.opponents(me_player)[1]; end
  def player_whose_turn_it_is; @my_match.game.next_turn; end
  def my_cards; me_player.cards; end
  def go_fish_card; @go_fish_card ||= @my_match.game.deck.cards[0]; end

  def save_and_reload
    @my_match.save
    @my_match.reload
  end
end

module GamePlay
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def make_it_someones_turn(player)
    @my_match.game.next_turn = player
    save_and_reload
    expect(@my_match.game.next_turn.user_id).to eq player.user_id
  end

  def have_king(players)
    players.each { |player| player.cards.unshift(build(:card_ks)) }
    save_and_reload
  end

  def have_jack(players)
    players.each { |player| player.cards.unshift(build(:card_js)) }
    save_and_reload
  end

  def make_my_request
    ['#card_0', '#opponent_0', '#fish_blue'].each { |icon| find(icon).click }
  end

  def make_opponent_request(match, player, opponent, rank)
    params = {
      'matchId' => match.id,
      'playerUserId' => player.user_id,
      'opponentUserId' => opponent.user_id,
      'rank' => rank
    }
    post("/card_request", params)
  end
end
