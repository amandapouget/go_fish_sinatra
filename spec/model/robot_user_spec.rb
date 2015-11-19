require 'spec_helper'

describe RobotUser do
  let(:user) { RobotUser.new }
  let(:other_user) { RobotUser.new }
  let(:match) { build(:match, :dealt, users: [user, other_user]) }

  it 'makes a play if it is his turn' do
    match.game.next_turn = user.player
    match.changed
    allow(match).to receive(:run_play).and_return(nil)
    match.notify_observers
    expect(match).to have_received(:run_play).with(user.player, any_args)
  end
end
