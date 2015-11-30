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

  def start_three_game(users:, robots:)
    @num_players = 3
    until @match do
      users.times { @match = match_maker.match(create(:real_user), 3) }
      robots.times { @match = match_maker.match(create(:robot_user), 3) }
    end
    MatchClientNotifier.new(@match)
    @me_player = @match.players.find { |player| player.is_a? Player }
    @first_opponent = @match.opponents(@me_player)[0]
    @second_opponent = @match.opponents(@me_player)[1]
    @go_fish_card = @match.game.deck.cards[0]
    @player_whose_turn_it_is = @match.game.next_turn
  end

  def expect_page_has_cards(cards, expect_true = true)
    cards.each { |card| expect(page.has_selector?("img[src = '#{card.icon}']")) } if expect_true
    cards.each { |card| expect(page.has_no_selector?("img[src = '#{card.icon}']")) } unless expect_true
  end

  def my_cards
    @me_player.cards
  end

  def current_cards_icons
    find_all('.your-cards').to_a.map! { |card| card = card['src'] }
  end

  def game_with_three_players_each_has_one_ace
    reset
    start_three_game(users: 3, robots: 0)
    @match.players.each { |player| player.cards = [build(:card_as)] }
  end

  def game_with_one_user_two_robots_each_has_one_different_card
    reset
    start_three_game(users: 1, robots: 2)
    cards = [build(:card_as), build(:card_ks), build(:card_qs)]
    @match.players.each_with_index { |player, index| player.cards = [cards[index]] }
  end

  def visit_player_page
    visit "/#{@match.id}/player/0"
    expect_page_ready
  end

  def expect_page_ready
    expect(page).to have_selector '#ready'
  end
end

module GamePlay
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def make_it_someones_turn(player)
    @match.game.next_turn = player
  end

  def have_king(players)
    players.each { |player| player.cards.unshift(build(:card_ks)) }
  end

  def have_jack(players)
    players.each { |player| player.cards.unshift(build(:card_js)) }
  end

  def make_my_request
    ['#card_0', '#opponent_0', '#fish_blue'].each { |icon| find(icon).click }
  end

  def make_opponent_request(match, player, opponent, rank)
    params = {
      'match_id' => match.id,
      'player_index' => match.players.index(player),
      'opponent_index' => match.players.index(opponent),
      'rank' => rank
    }
    post("/#{match.id}/card_request", params)
  end
end
