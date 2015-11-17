class Spinach::Features::StartGame < Spinach::FeatureSteps
  include FreshGameCreate

  step 'I am waiting for my game to start' do
    reset
    @num_players = 3 # more sad magic number
    fill_form("Amanda", @num_players)
    @user = PENDING_USERS[@num_players][0]
  end

  step 'the game is short one player' do
    (@num_players - 2).times { PENDING_USERS[@num_players] << build(:user) }
  end

  step 'the wrong kind of player joins' do
    add_player(@num_players - 1)
  end

  step 'it continues to wait for the right player' do
    expect(PENDING_USERS[@num_players].size).to eq @num_players - 1
    expect(current_path).to match /wait/
  end

  step 'the right kind of player joins' do
    add_player(@num_players)
  end

  step 'it starts our game' do
    expect(page.has_current_path?(/.*\/player\/.*/, :wait => 5)).to be true
    expect(page).to have_content(@user.name)
    expect(page).to have_content('Go Fish')
    expect(PENDING_USERS[@num_players].size).to eq 0
    expect(find_all('.player').size).to eq @num_players
  end

  step 'no one joins so I ask to play robots' do
    click_button 'Play With Robots'
  end
end
