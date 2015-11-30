class Spinach::Features::StartGame < Spinach::FeatureSteps
  include FreshGameCreate

  step 'I am waiting for my game to start' do
    reset
    @num_players = 3
    fill_form("Appleseed", @num_players)
    @user = match_maker.pending_users[@num_players][0]
  end

  step 'the game is short one player' do
    (@num_players - 2).times { match_maker.pending_users[@num_players] << create(:real_user) }
  end

  step 'the wrong kind of player joins' do
    add_player(@num_players - 1)
  end

  step 'it continues to wait for the right player' do
    expect(match_maker.pending_users[@num_players].size).to eq @num_players - 1
    expect(current_path).to match /wait/
  end

  step 'the right kind of player joins' do
    add_player(@num_players)
  end

  step 'it starts our game' do
    expect(page).to have_current_path /.*\/player\/.*/
    expect(page).to have_content(@user.name)
    expect(page).to have_content('Go Fish')
    expect(match_maker.pending_users[@num_players]).not_to include @user
    expect(find_all('.player').size).to eq @num_players
  end

  step 'I ask to play robots because no one has joined' do
    expect_page_ready
    click_button 'Play With Robots'
  end
end
