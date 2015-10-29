require 'spec_helper'

describe User do
  let(:user) { User.new(name: "Amanda") }
  let(:user2) { User.new() }
  let(:match) { Match.new() }
  let(:match2) { Match.new() }

  after do
    User.clear
  end

  it 'has a unique id' do
    expect(user.id).to eq user.object_id
    expect(user.id == user2.id).to be false
  end

  it 'has a name' do
    expect(user.name).to eq "Amanda"
  end

  it 'stores the last known client socket connection' do
    expect(user.client).to be nil
  end

  it 'returns the right user when given just an id' do
    id = user.id
    expect(User.find(id)).to eq user
  end

  it 'knows what matches it has played but does not allow duplicates' do
    user.add_match(match)
    user.add_match(match)
    user.add_match(match2)
    expect(user.matches).to match_array [match.object_id, match2.object_id]
  end

  it 'knows if a match is currently in session and which one' do
    user.add_match(match)
    expect(user.current_match).to eq match.object_id
  end

  it 'ends a match by removing the current_match' do
    user.add_match(match)
    user.end_current_match
    expect(user.current_match).to be nil
  end

  it 'returns a list of all users' do
    user.save
    expect(User.all).to eq [user]
  end

  it 'erases all users from the program' do
    user.save
    user2.save
    User.clear
    expect(User.all).to eq []
  end

  it 'tells you if its current match is in progress' do
    user.current_match = match.object_id
    expect(user.match_in_progress?).to be true
    match.game.deal
    expect(user.match_in_progress?).to be true
    match.end_match
    expect(user.match_in_progress?).to be false
  end
end

describe NullUser do
  let(:nulluser) { NullUser.new }
  let(:match) { Match.new() }
  let(:user) { User.new(name: "Amanda") }

  it 'it has nil or empty array values for all attributes of regular User' do
    expect(nulluser.id).to be nil
    expect(nulluser.matches).to eq []
    expect(nulluser.name).to be nil
    expect(nulluser.client).to be nil
    expect(nulluser.current_match).to be nil
  end

  it 'does not raise exceptions when regular User methods are called on it' do
    expect { nulluser.save }.to_not raise_exception
    expect { nulluser.add_match(match) }.to_not raise_exception
    expect { nulluser.end_current_match }.to_not raise_exception
    expect { nulluser.current_match_in_progress? }.to_not raise_exception
  end

  it 'calls equal any two nullusers' do
    expect(nulluser == NullUser.new).to be true
  end

  it 'returns false when testing equality with a regular user' do
    expect(nulluser == user).to be false
  end
end
