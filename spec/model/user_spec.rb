require 'spec_helper'

describe User do
  let(:user) { build(:user) }
  let(:user2) { build(:user) }
  let(:match) { Match.new() }
  let(:match2) { Match.new() }

  after do
    User.clear
  end

  it 'has a name' do
    expect(user.name).to be > ""
  end

  it 'stores the last known client socket connection' do
    expect(user.client).to be nil
  end

  it 'returns the right user when given just an id' do
    expect(User.find(user.object_id)).to eq user
  end

  it 'limits its search when given an optional array of users' do
    users = [user2]
    expect(User.find(user.object_id, users)).to eq nil
  end

  it 'knows what matches it has played but does not allow duplicates' do
    2.times { user.add_match(match) }
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

  describe NullUser do
    let(:nulluser) { build(:null_user) }
    let(:nulluser2) { build(:null_user) }

    it 'it has nil or empty array values for all attributes of regular User' do
      expect(nulluser.matches).to eq []
      expect(nulluser.name).to be nil
      expect(nulluser.client).to be nil
      expect(nulluser.current_match).to be nil
    end

    it 'does not raise exceptions when regular User methods are called on it' do
      expect { nulluser.save }.to_not raise_exception
      expect { nulluser.add_match(match) }.to_not raise_exception
      expect { nulluser.end_current_match }.to_not raise_exception
    end

    it 'calls equal any two nullusers' do
      expect(nulluser == nulluser2).to be true
      expect(nulluser.eql?(nulluser2)).to be true
      expect(nulluser.hash == nulluser2.hash).to be true
    end

    it 'returns false when testing equality with a regular user' do
      expect(nulluser == user).to be false
      expect(nulluser.eql?(user)).to be false
      expect(nulluser.hash == user.hash).to be false
    end
  end
end
