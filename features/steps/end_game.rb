class Spinach::Features::EndGame < Spinach::FeatureSteps
  include FreshGameCreate
  include GamePlay

  step 'the game has started' do
    game_with_three_players_one_card_each
  end

  step 'I run out of cards' do
    make_it_someones_turn(@first_opponent)
    make_opponent_request(@match, @first_opponent, @me_player, "two")
  end

  step 'it tells me the game is over and displays everyone\'s final score' do
    visit_player_page
    expect(page).to have_content /Game over/
    @match.players.each { |player| expect(page).to have_content /#{player.name}: [0123456789]*/ }
  end

  step 'an opponent runs out of cards' do
    make_it_someones_turn(@me_player)
    visit_player_page
    make_my_request
    expect(@match.over).to be true
    expect(@match.game.game_over?).to be true
    expect(@first_opponent.out_of_cards?).to be true
  end

  step 'the deck runs out of cards' do
    @match.game.deck.cards = []
    have_ace([@me_player, @match.game.deck])
    visit_player_page
    make_my_request
  end
end
