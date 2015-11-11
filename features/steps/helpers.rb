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
    @match = Match.new([User.new(name: "Bob"), User.new(name: "Charlie"), User.new(name: "David")])
    @me_player = @match.players[0]
    @first_opponent = @match.opponents(@me_player)[0]
    @second_opponent = @match.opponents(@me_player)[1]
    @go_fish_card = @match.game.deck.cards[0]
    @player_whose_turn_it_is = @match.game.next_turn
  end

  def expect_page_has_cards(cards, expect_true = true)
    visit "/#{@match.object_id}/player/0"
    cards.each { |card| expect(page.has_selector?("img[src = '#{card.icon}']", :wait => 5)).to be true } if expect_true
    cards.each { |card| expect(page.has_no_selector?("img[src = '#{card.icon}']", :wait => 5)).to be true } unless expect_true
  end

  def my_cards
    @me_player.cards
  end

  def current_cards_icons
    find_all('.your-cards').to_a.map! { |card| card = card['src'] }
  end

  def visit_player_page
    visit "/#{@match.object_id}/player/0"
  end

  def game_with_three_players_one_card_each
    reset
    start_three_game
    everyone_has_at_least_one_card(@match)
  end

  def everyone_has_at_least_one_card(match)
    match.players.each { |player| player.cards = [build(:card_2d)] }
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

  def have_ace(players)
    players.each { |player| player.cards.unshift(build(:card_as)) }
  end

  def have_jacks(players)
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
