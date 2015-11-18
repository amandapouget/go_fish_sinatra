require 'pry'
sleep 4
module FreshGameCreate
  include Spinach::DSL

  def reset
    PENDING_USERS.each_key { |num_players| PENDING_USERS[num_players] = [] }
    Match.clear
  end

  def fill_form(name, num_players)
    visit '/'
    fill_in 'name', :with => name
    choose(num_players)
    click_button 'Start Game'
  end

  def add_player(num_players)
    fill_form("Anonymous", num_players)
  end

  def start_three_game # for factory
    @num_players = 3
    @match = Match.new([User.new(name: 'Bob'), User.new(name: 'Charlie'), User.new(name: 'David')])
    @me_player = @match.players[0]
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
    start_three_game
    @match.players.each { |player| player.cards = [build(:card_as)] }
  end

  def visit_player_page
    visit "/#{@match.object_id}/player/0"
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
      'match_id' => match.object_id,
      'player_object_id' => player.object_id,
      'opponent_object_id' => opponent.object_id,
      'rank' => rank
    }
    post("/#{match.object_id}/card_request", params)
  end
end
