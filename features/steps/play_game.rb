class Spinach::Features::PlayGame < Spinach::FeatureSteps
  include FreshGameCreate
  include GamePlay

  step 'the game has started' do
    game_with_three_players_one_card_each
  end

  step 'it is already my turn' do
    make_it_someones_turn(@me_player)
    @player_whose_turn_it_is = @me_player
  end

  step 'it is already the turn of my first opponent' do
    make_it_someones_turn(@first_opponent)
    @player_whose_turn_it_is = @first_opponent
  end

  step 'the request is ignored' do
    expected_card_icons = @my_preplay_cards.map { |card| card.icon }
    expect(current_cards_icons).to match_array expected_card_icons
  end

  step 'I ask my first opponent for cards he has' do
    have_ace([@me_player, @first_opponent])
    @my_preplay_cards = my_cards
    visit_player_page
    make_my_request
  end

  step 'I ask my first opponent for cards he does not have' do
    have_ace([@me_player])
    @my_preplay_cards = my_cards
    visit_player_page
    make_my_request
  end

  step 'my first opponent asks me for cards I have' do
    have_ace([@me_player, @first_opponent])
    @my_preplay_cards = my_cards
    @aces = my_cards.select { |card| card.rank == "ace" }
    visit_player_page
    make_opponent_request(@match, @first_opponent, @me_player, "ace")
  end

  step 'my first opponent asks me for cards I do not have' do
    have_ace([@first_opponent])
    @my_preplay_cards = my_cards
    visit_player_page
    make_opponent_request(@match, @first_opponent, @me_player, "ace")
  end

  step 'my first opponent asks my second opponent for cards he has' do
    have_ace([@first_opponent, @second_opponent])
    visit_player_page
    make_opponent_request(@match, @first_opponent, @second_opponent, "ace")
  end

  step 'my first opponent asks my second opponent for cards he does not have' do
    have_ace([@first_opponent])
    visit_player_page
    make_opponent_request(@match, @first_opponent, @second_opponent, "ace")
  end

  step 'it gives me the cards' do
    expect_page_has_cards(my_cards)
  end

  step 'it takes the cards from me' do
    expect_page_has_cards(my_cards)
    expect_page_has_cards(@aces, false)
  end

  step 'it makes me go fish' do
    expect_page_has_cards([@go_fish_card])
  end

  step 'I go fish and draw the rank I asked for' do
    have_ace([@me_player, @match.game.deck])
    @match.run_play(@me_player, @first_opponent, "ace")
  end

  step 'I go fish and draw a different rank' do
    have_ace([@me_player])
    have_jack([@match.game.deck])
    @match.run_play(@me_player, @first_opponent, "ace")
  end

  step 'my first opponent goes fish and draws the rank he asked for' do
    have_ace([@first_opponent, @match.game.deck])
    @match.run_play(@first_opponent, @me_player, "ace")
  end

  step 'my first opponent goes fish and draws a different rank' do
    have_ace([@first_opponent])
    have_jack([@match.game.deck])
    @match.run_play(@first_opponent, @me_player, "ace")
  end

  step 'it tells me what I asked for' do
    expect(page).to have_content /#{@me_player.name} asked \S* for aces/
  end

  step 'it tells me what my first opponent asked for' do
    expect(page).to have_content /#{@first_opponent.name} asked \S* for aces/
  end

  step 'it tells me cards were won' do
    expect(page).to have_content "got cards"
  end

  step 'it tells me fishing happened' do
    visit_player_page
    expect(page).to have_content "went fish"
  end

  step 'it tells me the right rank was drawn' do
    visit_player_page
    expect(page).to have_content "got one"
  end

  step 'turn advances' do
    expect(page).not_to have_content /#{@player_whose_turn_it_is.name}'s turn/
  end

  step 'turn does not advance' do
    expect(page).to have_content /#{@player_whose_turn_it_is.name}'s turn/
  end
end
