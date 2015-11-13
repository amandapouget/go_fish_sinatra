require 'spec_helper'

describe Match do
  [:user1, :user2, :user3, :user4, :user5].each { |user| let(user) { build(:user) } }
  let(:card_ad) { build(:card_ad) }
  let(:match) { Match.new([user1, user2, user3, user4, user5]) }
  let(:users) { match.users }
  let(:players ) { match.players }

  before do
    match
  end

  after do
    Match.clear
  end

  it 'can tell you how many players it has' do
    expect(match.num_players).to eq match.players.length
  end

  it 'initializes with a game and users, an array of the users, an empty message, plus players connected to the game with unique go_fish icons' do
    expect(match.game).to be_a Game
    expect(match.users).to match_array [user1, user2, user3, user4, user5]
    expect(match.message).to eq "#{match.players[0].name}, click card, player & me to request cards!"
    expect(match.game.players).to match_array match.players
    icons = Dir.glob("./public/images/players/*.png")
    players.each { |player| expect(icons).to include "./public#{player.icon}" }
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
    expect(Match.find(match.object_id)).to eq match
  end

  it 'can make and save a fake match' do
    (MIN_PLAYERS...MAX_PLAYERS).each { |num_players| expect(Match.fake(num_players).users.length).to eq num_players }
    fake_match = Match.fake(MAX_PLAYERS)
    expect(Match.find(fake_match.object_id)).to eq fake_match
  end

  it 'returns nil if no such match is found' do
    expect(Match.find(0)).to eq nil
  end

  it 'can tell you which player is matched to one of its users' do
    expect(match.player(users[0])).to eq players[0]
  end

  it 'can tell you which user is matched to one of its players' do
    expect(match.user(players[0])).to eq users[0]
  end

  it 'can tell you a players opponents' do
    expect(match.opponents(players[0])).to match_array players[1..4]
  end

  it 'gives you the players opponents in a rotating order depending on which player is called' do
    order = match.players.clone
    players.each do |player|
      order.push(order.shift)
      expect(match.opponents(player)).to eq order[0..3]
    end
  end

  it 'can tell you how many cards are left in the game deck' do
    expect(match.deck_count).to eq match.game.deck.count_cards
  end

  it 'returns nil when searching for a player or user that is not part of this match' do
    expect(match.user(build(:player))).to eq build(:null_user)
    expect(match.player(build(:user))).to eq build(:null_player)
  end

  it 'can find a player when given a name' do
    expect(match.player_from_name("Amanda")).to eq players[0]
  end

  it 'can find a player when given an object_id' do
    expect(match.player_from_object_id(match.players[0].object_id)).to eq match.players[0]
  end

  it 'returns a nullplayer if it cant find such a player' do
    expect(match.player_from_name("not_a_name")).to be_a NullPlayer
  end

  it 'gives me player state' do
    match.player(user1).add_card(card_ad)
    json = match.player_state(user1)
    expect(json[:type]).to eq "player_state"
    expect(json[:player_cards]).to eq "[{\"rank\":\"ace\",\"suit\":\"diamonds\"}]"
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

  describe 'can run a play' do
    let(:card_as) { build(:card_as) }
    let(:card_ah) { build(:card_ah) }
    let(:card_2h) { build(:card_2h) }
    let(:card_2d) { build(:card_2d) }
    let(:player0) { match.players[0] }
    let(:player1) { match.players[1] }

    before { match.players[1..4].each { |player| player.cards = [card_2h] } }

    it 'works when a player wins cards' do
      player0.add_card(card_as)
      player1.add_card(card_ah)
      match.run_play(player0, player1, "ace")
      expect(player0.cards).to match_array [card_as, card_ah]
      expect(player1.cards).to match_array [card_2h]
      expect(match.message).to eq "#{player0.name} asked #{player1.name} for aces & got cards! It's #{player0.name}'s turn!"
    end

    it 'works when a player does not win cards, goes fish, and gets card he was looking for' do
      player0.add_card(card_as)
      match.game.deck.cards.unshift(card_ah)
      match.run_play(player0, player1, "ace")
      expect(player0.cards).to match_array [card_as, card_ah]
      expect(player1.cards).to match_array [card_2h]
      expect(match.message).to eq "#{player0.name} asked #{player1.name} for aces & went fish & got one! It's #{player0.name}'s turn!"
    end

    it 'works when a player does not win cards or get the right card in go fish' do
      player0.add_card(card_as)
      fish_card = match.game.deck.cards[0]
      match.run_play(player0, player1, "ace")
      expect(player0.cards).to match_array [card_as, fish_card]
      expect(player1.cards).to match_array [card_2h]
      expect(match.message).to eq "#{player0.name} asked #{player1.name} for aces & went fish! It's #{player1.name}'s turn!"
    end

    it 'works when the game is over as a result' do
      player0.add_card(card_2d)
      match.run_play(player0, player1, "two")
      expect(player0.cards).to match_array [card_2d, card_2h]
      expect(player1.cards).to match_array []
      expect(match.over).to be true
      expect(match.message).to eq "#{player0.name} asked #{player1.name} for twos & got cards! Game over! Winner: none"
    end
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
  let(:player) { build(:null_player)}
  let(:user) { build(:user) }

  it 'does nothing in response to match methods' do
    expect(nullmatch.user(player)).to eq nil
    expect(nullmatch.player(user)).to eq nil
    expect(nullmatch.users).to eq []
    expect(nullmatch.players).to eq []
    expect(nullmatch.player_from_name("any string")).to eq nil
    expect { nullmatch.save }.to_not raise_exception
    expect(nullmatch.to_json).to eq nil
    expect(nullmatch.num_players).to eq 0
    expect(nullmatch.opponents(player)).to eq []
    expect(nullmatch.deck_count).to eq 0
    expect(nullmatch.player_from_object_id(player.object_id)).to eq nil
    expect(nullmatch.message).to eq nil
  end

  it 'calls equal two nullmatches but not a nullmatch and a regular match' do
    expect(nullmatch == Match.new).to be false
    expect(nullmatch == NullMatch.new).to be true
  end
end
