class Spinach::Features::PlayGameWithRobots < Spinach::FeatureSteps
  include FreshGameCreate
  include GamePlay

  step 'the game has started with robots' do
    game_with_one_user_two_robots_each_has_one_different_card
  end

  step 'it is already my turn' do
    make_it_someones_turn(me_player)
  end

  step 'it is already the turn of my first opponent' do
    make_it_someones_turn(first_opponent)
  end

  step 'the request is ignored' do
    expect(current_cards_icons).to match_array @my_preplay_cards
  end

  step 'I ask my first opponent for cards he has' do
    have_king([me_player, first_opponent])
    @my_preplay_cards = my_cards.map { |card| card.icon }
    visit_player_page
    make_my_request
  end

  step 'I ask my first opponent for cards he does not have' do
    visit_player_page
    make_my_request
  end

  step 'turn advances correctly and informs me of play' do
    expect(page).to have_content /#{second_opponent.name} asked \S* for/
    expect(page).to have_content /#{me_player.name}\'s turn/
  end
end
