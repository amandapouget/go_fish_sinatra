require 'spec_helper'

describe NullUser do
  let(:real_user) { create(:real_user) }
  let(:nulluser) { build(:null_user) }
  let(:nulluser2) { build(:null_user) }

  it 'it has nil or empty array values for all attributes of regular User' do
    expect(nulluser.matches).to eq []
    expect(nulluser.name).to eq "none"
    expect(nulluser.client).to be nil
  end

  it 'does not raise exceptions when regular User methods are called on it' do
    expect { nulluser.save }.to_not raise_exception
  end

  it 'calls equal any two nullusers' do
    expect(nulluser == nulluser2).to be true
    expect(nulluser.eql?(nulluser2)).to be true
    expect(nulluser.hash == nulluser2.hash).to be true
  end

  it 'returns false when testing equality with a real user' do
    expect(nulluser == real_user).to be false
    expect(nulluser.eql?(real_user)).to be false
    expect(nulluser.hash == real_user.hash).to be false
  end
end
