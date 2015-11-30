require 'spec_helper'

describe RealUser do
  let(:real_user) { create(:real_user) }
  let(:real_user2) { create(:real_user) }

  after do
    User.delete_all
  end

  it 'must have a name' do
    expect(RealUser.new.save).to be false
  end

  it 'stores the last known client socket connection' do
    expect(real_user.client).to be nil
  end

  it 'returns the right user when given just an id' do
    expect(User.find(real_user.id)).to eq real_user
  end

  describe 'be a part of matches' do
    let(:match) { create(:match, users: [real_user, real_user2]) }
    let(:match2) { create(:match, users: [real_user, real_user2]) }

    it 'knows what matches it has played' do
      expect(real_user.matches).to match_array [match, match2]
    end
  end
end
