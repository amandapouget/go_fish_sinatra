class Spinach::Features::PlayGame < Spinach::FeatureSteps
  include FreshGameCreate

  step 'the game is on-going' do
    reset_pending
    reset_matches
    @match = start_three_game("Amanda")
    @me_player = @match.players[0]
    expect(@me_player.name).to eq "Amanda"
    visit "/#{@match.object_id}/player/0"
    @my_cards = find_all('.your-cards')
  end

  step 'it is already my turn' do
    @match.game.next_turn = @me_player
    @player_whose_turn_it_is = @me_player
  end

  step 'it is already another player\'s turn' do
    @match.game.next_turn = @opponent_making_play
    @player_whose_turn_it_is = @opponent_making_play
  end

  step 'it is still my turn' do
    expect(@match.game.next_turn).to eq @me_player
  end

  step 'it is someone else\'s turn' do
    expect(@match.game.next_turn).not_to eq @player_whose_turn_it_is
  end

  step 'it is still their turn' do
    expect(@match.game.next_turn).to eq @opponent_making_play
  end

  step 'the request is ignored' do
    expect(find_all('.your-cards')).to match_array @my_cards
  end

  step 'I ask an opponent for cards of a given rank' do
    find('#card_0').click
    find('#opponent_0').click
    find('#fish_blue').click
  end

  step 'they have cards of that rank' do
    pending 'step not implemented'
  end

  step 'it tells me what I asked for' do
    pending 'step not implemented'
  end

  step 'it tells me I got cards' do
    pending 'step not implemented'
  end

  step 'it gives me the cards' do
    pending 'step not implemented'
  end

  step 'they ask me for cards of a given rank' do
    pending 'step not implemented'
  end

  step 'I have cards of that rank' do
    pending 'step not implemented'
  end

  step 'it tells me what they asked for' do
    pending 'step not implemented'
  end

  step 'it gives them the cards' do
    pending 'step not implemented'
  end

  step 'they ask someone else for cards of a given rank' do
    pending 'step not implemented'
  end

  step 'it tells me they got cards' do
    pending 'step not implemented'
  end

  step 'they do not have cards of that rank' do
    pending 'step not implemented'
  end

  step 'it makes me go Fish' do
    pending 'step not implemented'
  end

  step 'it tells me I went fish' do
    pending 'step not implemented'
  end

  step 'I do not have cards of that rank' do
    pending 'step not implemented'
  end

  step 'it makes them go Fish' do
    pending 'step not implemented'
  end

  step 'it tells me they went Fish' do
    pending 'step not implemented'
  end

  step 'I do not get the cards I asked for' do
    pending 'step not implemented'
  end

  step 'I go fish' do
    pending 'step not implemented'
  end

  step 'I draw the rank I asked for' do
    pending 'step not implemented'
  end

  step 'it tells me I drew the right rank' do
    pending 'step not implemented'
  end

  step 'Someone else does not get the cards they asked for' do
    pending 'step not implemented'
  end

  step 'they go fish' do
    pending 'step not implemented'
  end

  step 'they draw the rank they asked for' do
    pending 'step not implemented'
  end

  step 'it tells me they drew the right rank' do
    pending 'step not implemented'
  end

  step 'I draw a different rank from the one I asked for' do
    pending 'step not implemented'
  end

  step 'they draw a different rank from the one they asked for' do
    pending 'step not implemented'
  end
end
