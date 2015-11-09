class Spinach::Features::StartGame < Spinach::FeatureSteps
  include FreshGameCreate

  step 'I am waiting for my game to start' do
    reset_pending
    reset_matches
    @num_players = 3 # more sad magic number
    fill_form("Amanda", @num_players)
    click_button 'Start Game'
    @user = PENDING_USERS[@num_players][0]
  end

  step 'the game is short one player' do
    (@num_players - 2).times { PENDING_USERS[@num_players] << User.new }
  end

  step 'the wrong kind of player joins' do
    add_player(@num_players - 1)
  end

  step 'it continues to wait for the right player' do
    expect(PENDING_USERS[@num_players].length).to eq @num_players - 1
    expect(current_path).to match /wait/
  end

  step 'the right kind of player joins' do
    add_player(@num_players)
  end

  step 'it starts our game' do
    expect(page).to have_content(@user.name, :wait => 5 )
    expect(page).to have_content('Go Fish')
    expect(PENDING_USERS[@num_players].length).to eq 0
    expect(Match.all[0].players.length).to eq @num_players
    expect(Match.all[0].users).to include @user
    expect(current_path).to match /.*\/player\/.*/
  end
end
