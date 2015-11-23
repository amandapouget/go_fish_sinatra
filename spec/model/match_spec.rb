# require 'spec_helper'
#
# describe(List) do
#   it('tells which tasks are in it') do
#     list = List.create({name: "list"})
#     task1 = Task.create({description: "my task", list_id: list.id})
#     task2 = Task.create({description: "my other task", list_id: list.id})
#     expect(list.tasks).to match_array([task1,task2])
#   end
#
# end

require 'spec_helper'

describe Match do
  let(:match) { build(:match, num_players: MAX_PLAYERS) }
  let(:users) { match.users }
  let(:players ) { match.players }

  it 'initializes with a game and users, an array of the users, an array of players and the first message' do
    expect(match.game).to be_a Game
    expect(match.users).to match_array [users[0], users[1], users[2], users[3], users[4]]
    expect(match.game.players).to match_array players
    expect(match.message).to eq players[0].name + Match::FIRST_PROMPT
  end

  it 'upon initialization, saves self to the matches class array' do
    expect(Match.all).to include match
  end

  it 'can clear all saved matches' do
    Match.clear
    expect(Match.all).to eq []
  end

  it 'can find a match based on object_id' do
    expect(Match.find(match.object_id)).to eq match
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
    expect(match.opponents(players[0])).to match_array players[1...players.size]
  end

  it 'gives you the players opponents in a rotating order depending on which player is called' do
    order = players.clone
    players.each do |player|
      order.push(order.shift)
      expect(match.opponents(player)).to eq order[0...players.size - 1]
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
    expect(match.player_from_name(players[0].name)).to eq players[0]
  end

  it 'can find a player when given an object_id' do
    expect(match.player_from_id(players[0].object_id)).to eq players[0]
  end

  it 'returns a nullplayer if it cant find such a player' do
    expect(match.player_from_name("not_a_name")).to be_a NullPlayer
  end

  it 'gives me the game from one player point of view' do
    players[0].add_card(build(:card))
    players[0].books = build(:book)
    view_in_json = match.view(players[0])
    view_parsed = JSON.parse(view_in_json)
    expect(view_parsed["type"]).to eq "player_view"
    expect(view_parsed["message"]).to eq match.message
    expect(view_parsed["player"] == JSON.parse(players[0].to_json)).to be true
    expect(view_parsed["opponents"] == match.opponents(players[0]).map{ |opponent| JSON.parse(opponent.to_json) }).to be true
    expect(view_parsed["scores"]).to match_array players.map { |player| [player.name, player.books.size] }.push(["Fish Left", match.game.deck.count_cards])
  end

  describe 'can run a play' do
    [:card_as, :card_ah, :card_2h, :card_2d].each { |card| let(card) { build(card) } }
    before { players[1...players.size].each { |player| player.cards = [card_2h] } }

    it 'works when a player wins cards' do
      players[0].add_card(card_as)
      players[1].add_card(card_ah)
      match.run_play(players[0], players[1], "ace")
      expect(players[0].cards).to match_array [card_as, card_ah]
      expect(players[1].cards).to match_array [card_2h]
      expect(match.message).to eq "#{players[0].name} asked #{players[1].name} for aces & got cards! It's #{players[0].name}'s turn!"
    end

    it 'works when a player does not win cards, goes fish, and gets card he was looking for' do
      players[0].add_card(card_as)
      match.game.deck.cards.unshift(card_ah)
      match.run_play(players[0], players[1], "ace")
      expect(players[0].cards).to match_array [card_as, card_ah]
      expect(players[1].cards).to match_array [card_2h]
      expect(match.message).to eq "#{players[0].name} asked #{players[1].name} for aces & went fish & got one! It's #{players[0].name}'s turn!"
    end

    it 'works when a player does not win cards or get the right card in go fish' do
      players[0].add_card(card_as)
      match.game.deck.cards.unshift(card_2d)
      match.run_play(players[0], players[1], "ace")
      expect(players[0].cards).to match_array [card_as, card_2d]
      expect(players[1].cards).to match_array [card_2h]
      expect(match.message).to eq "#{players[0].name} asked #{players[1].name} for aces & went fish! It's #{players[1].name}'s turn!"
    end

    it 'works when the game is over as a result' do
      players[0].add_card(card_2d)
      match.run_play(players[0], players[1], "two")
      expect(players[0].cards).to match_array [card_2d, card_2h]
      expect(players[1].cards).to match_array []
      expect(match.message).to eq "#{players[0].name} asked #{players[1].name} for twos & got cards! Game over! Winner: none"
      expect(match.over).to be true
    end

    it 'informs observers when a play is complete' do
      my_observer = double(update: nil)
      expect(my_observer).to receive(:update)
      match.add_observer(my_observer)
      match.run_play(players[0], players[1], 'two')
    end
  end

  it 'can end itself' do
    match.end_match
    expect(match.over).to be true
  end

  it 'can tell you if it has been ended' do
    expect(match.over).to be false
    match.end_match
    expect(match.over).to be true
  end
end
