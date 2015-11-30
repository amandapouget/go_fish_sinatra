require 'spec_helper'

describe RobotUser do
  let!(:user) { create(:robot_user) }
  let!(:other_user) { create(:robot_user) }
  let!(:match) { create(:match, :dealt, users: [user, other_user]) }

  it 'makes a play when it is his turn' do
    start_cards = user.player.cards
    match.game.next_turn = user.player
    match.save
    user.make_play(match)
    expect(user.player.cards).not_to match_array start_cards
  end

  it 'does nothing if it is not his turn' do
    start_cards = user.player.cards
    match.game.next_turn = other_user.player
    match.save
    user.make_play(match)
    expect(user.player.cards).to match_array start_cards
  end

  it 'has a name that matches its player name' do
    expect(user.name).to eq match.player(user).name
  end
end
