class Spinach::Features::EndGame < Spinach::FeatureSteps
  include FreshGameCreate
  include GamePlay

  step 'the game has started' do
    game_with_three_players_each_has_one_ace
  end

  step 'I run out of cards' do
    make_it_someones_turn(first_opponent)
    visit_player_page
    make_opponent_request(@my_match, first_opponent, me_player, "ace")
  end

  step 'an opponent runs out of cards' do
    make_it_someones_turn(me_player)
    visit_player_page
    make_my_request
  end

  step 'the deck runs out of cards' do
    make_it_someones_turn(me_player)
    have_ace([me_player, first_opponent])
    visit_player_page
    @my_match.game.deck.cards = []
    make_my_request
  end

  step 'it tells me the game is over and displays everyone\'s final score' do
    expect(page).to have_content /Game over/
    @my_match.players.each { |player| expect(page).to have_content /#{player.name}: [0123456789]*/ }
  end
end
