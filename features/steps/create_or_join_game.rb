class Spinach::Features::CreateOrJoinGame < Spinach::FeatureSteps
  include FreshGameCreate

  step 'I tell it my name and how many players I want' do
    @my_name = "Bear Trapp"
    fill_form(@my_name, @num_players)
  end

  step 'no pending game exists with the number of players I want' do
    reset
    @num_players = 3
  end

  step 'it creates the kind of pending game I want and waits for players to join' do
    expect(match_maker.pending_users[@num_players].size).to eq 1
    expect(match_maker.pending_users[@num_players][0].name).to eq @my_name
    expect(current_path).to match /\/wait/
  end

  step 'a pending game exists for the number of players I want' do
    reset
    @num_players = 3
    match_maker.pending_users[@num_players] << create(:real_user)
    expect(match_maker.pending_users[@num_players].size).to eq 1
  end

  step 'it joins me to the kind of pending game I want and waits for players to join' do
    expect(match_maker.pending_users[@num_players].size).to eq 2
    expect(match_maker.pending_users[@num_players][1].name).to eq @my_name
    expect(current_path).to match /\/wait/
  end
end
