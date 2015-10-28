require 'spec_helper'

describe Match do
  let(:user1) { User.new(name: "Amanda") }
  let(:user2) { User.new(name: "Vianney") }
  let(:user3) { User.new(name: "Frederique") }
  let(:match) { Match.new([user1, user2, user3]) }
  let(:users) { match.users }
  let(:players ) { match.players }

  before do
    match
  end

  after do
    Match.clear
  end

  it 'initializes with a game and users, an array of the users, plus players connected to the game' do
    expect(match.game).to be_a Game
    expect(match.users).to match_array [user1, user2, user3]
    expect(match.game.players).to match_array match.players
  end

  it 'upon initialization, makes the user acknowledge it as the current_match' do
    users.each { |user| expect(user.current_match).to eq match.object_id }
  end

  it 'upon initialization, saves self to the matches class array' do
    expect(Match.all[0]).to eq match
  end

  it 'can clear all saved matches' do
    Match.clear
    expect(Match.all).to eq []
  end

  it 'can find a match based on object_id' do
    expect(Match.find_by_obj_id(match.object_id)).to eq match
  end

  it 'returns nil if no such match is found' do
    expect(Match.find_by_obj_id(0)).to eq nil
  end

  it 'can tell you which player is matched to one of its users' do
    expect(match.player(users[0])).to eq players[0]
  end

  it 'can tell you which user is matched to one of its players' do
    expect(match.user(players[0])).to eq users[0]
  end

  it 'returns nil when searching for a player or user that is not part of this match' do
    expect(match.user(Player.new)).to eq NullUser.new
    expect(match.player(User.new)).to eq NullPlayer.new
  end

  it 'can find a player when given a name' do
    expect(match.player_from_name("Amanda")).to eq players[0]
    expect(match.player_from_name("Vianney")).to eq players[1]
    expect(match.player_from_name("Frederique")).to eq players[2]
  end

  it 'returns a nullplayer if it cant find such a player' do
    expect(match.player_from_name("Bob")).to be_a NullPlayer
  end

  it 'gives me player state' do
    match.player(user1).add_card(Card.new(rank:'A', suit: 'S'))
    json = match.player_state(user1)
    expect(json[:type]).to eq "player_state"
    expect(json[:player_cards]).to eq [{rank: 'A', suit: 'S'}]
  end

  it 'can give you a json string containing the most critical information about the objects it contains' do
    expect(match.json_ready).to be_a Hash
    expect(match.json_ready[:type]).to eq "match_state"
  end

  it 'json_ready: if a user is passed, gives information only about that user' do
    json = match.json_ready(users[0])
    expect(json).to be_a Hash
    expect(json[:type]).to eq "player_state"
  end

  it 'can end itself' do
    match.end_match
    users.each { |user| expect(user.current_match).to be nil }
  end

  it 'can tell you if it has been ended' do
    expect(match.over).to be false
    match.end_match
    expect(match.over).to be true
  end
end

describe NullMatch do
  let(:nullmatch) { NullMatch.new }
  let(:player) { NullPlayer.new }
  let(:user) { User.new }

  it 'does nothing in response to match methods' do
    expect(nullmatch.user(player)).to eq nil
    expect(nullmatch.player(user)).to eq nil
    expect(nullmatch.users).to eq []
    expect(nullmatch.players).to eq []
    expect(nullmatch.player_from_name("any string")).to eq nil
    expect { nullmatch.save }.to_not raise_exception
    expect(nullmatch.to_json).to eq nil
  end

  it 'calls equal two nullmatches but not a nullmatch and a regular match' do
    expect(nullmatch == Match.new).to be false
    expect(nullmatch == NullMatch.new).to be true
  end
end
