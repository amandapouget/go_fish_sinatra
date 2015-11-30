require 'spec_helper'

describe Match do
  let(:match) { create(:match, num_players: MAX_PLAYERS) }
  let(:match_from_database) { Match.find_by_id(match.id) }
  let(:players ) { match.players }
  let(:users) { match.users }

  it 'writes a match to database and reads it out with the right attributes' do
    expect(match_from_database.users[0]).to be_a User
    expect(match_from_database.players[0]).to be_a Player
    expect(match_from_database.game).to be_a Game
    expect(match_from_database.users).to match_array users
    expect(players.map { |player| player.name }).to match_array users.map { |user| user.name }
    expect(match_from_database.message).to eq match_from_database.players[0].name + Match::FIRST_PROMPT
    expect(match_from_database.over).to eq false
    expect(match_from_database.hand_size).to eq match.hand_size
  end

  it 'creates the game correctly upon creation (as opposed to after database retrieval)' do
    expect(match.game).to be_a Game
    expect(players.map { |player| player.name }).to match_array users.map { |user| user.name }
  end

  it 'can tell you which player is matched to one of its users' do
    user = users[0]
    found_player = match.player(user)
    expect(found_player.name).to eq user.name
  end

  it 'can tell you which user is matched to one of its players' do
    player = match.players[0]
    found_user = match.user(player)
    expect(found_user.name).to eq player.name
  end

  it 'returns a nullobject when searching for a player or user that is not part of this match' do
    expect(match.user(build(:player))).to eq build(:null_user)
    expect(match.player(create(:real_user))).to eq build(:null_player)
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
    expect(match.game.deck.count_cards).to eq match.game.deck.count_cards
  end

  it 'can find a player when given a name' do
    expect(match.player_from_name(players[0].name)).to eq players[0]
  end

  it 'returns a nullplayer if it cant find such a player' do
    expect(match.player_from_name("not_a_name")).to be_a NullPlayer
  end

  it 'gives me the game from one player point of view' do
    players[0].add_card(build(:card))
    players[0].books = build(:book)
    view = JSON.parse(match.view(players[0]))
    expect(view["message"]).to eq match.message
    expect(view["player"]).to eq JSON.parse(players[0].to_json)
    expect(view["player_index"]).to eq 0
    expect(view["opponents"]).to eq match.opponents(players[0]).map { |opponent| {"index" => players.index(opponent), "name" => opponent.name, "icon" => opponent.icon} }
    expect(view["scores"]).to eq players.map { |player| [player.name, player.books.size] }.push(["Fish Left", match.game.deck.count_cards])
  end

  describe 'can run a play' do
    [:card_as, :card_ah, :card_2h, :card_2d].each { |card| let(card) { build(card) } }
    before { players[1...players.size].each { |player| player.cards = [card_2h] } }

    it 'works when a player wins cards' do
      players[0].add_card(card_as)
      players[1].add_card(card_ah)
      match.run_play(players[0], players[1], "ace")
      match.reload
      expect(players[0].cards).to match_array [card_as, card_ah]
      expect(players[1].cards).to match_array [card_2h]
      expect(match.message).to eq "#{players[0].name} asked #{players[1].name} for aces & got cards! It's #{players[0].name}'s turn!"
    end

    it 'works when a player does not win cards, goes fish, and gets the card he was looking for' do
      players[0].add_card(card_as)
      match.game.deck.cards.unshift(card_ah)
      match.run_play(players[0], players[1], "ace")
      match.reload
      expect(players[0].cards).to match_array [card_as, card_ah]
      expect(players[1].cards).to match_array [card_2h]
      expect(match.message).to eq "#{players[0].name} asked #{players[1].name} for aces & went fish & got one! It's #{players[0].name}'s turn!"
    end

    it 'works when a player does not win cards or get the right card in go fish' do
      players[0].add_card(card_as)
      match.game.deck.cards.unshift(card_2d)
      match.run_play(players[0], players[1], "ace")
      match.reload
      expect(players[0].cards).to match_array [card_as, card_2d]
      expect(players[1].cards).to match_array [card_2h]
      expect(match.message).to eq "#{players[0].name} asked #{players[1].name} for aces & went fish! It's #{players[1].name}'s turn!"
    end

    it 'works when the game is over as a result' do
      players[0].add_card(card_2d)
      match.run_play(players[0], players[1], "two")
      match.reload
      expect(players[0].cards).to match_array [card_2d, card_2h]
      expect(players[1].cards).to match_array []
      expect(match.message).to eq "#{players[0].name} asked #{players[1].name} for twos & got cards! Game over! Winner: none"
      expect(match.over).to be true
    end

    # it 'informs observers when a play is complete' do
    #   my_observer = double(update: nil)
    #   expect(my_observer).to receive(:update)
    #   match.add_observer(my_observer)
    #   match.run_play(players[0], players[1], 'two')
    # end
  end

  it 'can end itself' do
    match.end_match
    match.reload
    expect(match.over).to be true
  end

  it 'can tell you if it has been ended' do
    expect(match.over).to be false
    match.end_match
    match.reload
    expect(match.over).to be true
  end
end
