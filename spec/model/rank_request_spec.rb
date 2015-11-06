require 'spec_helper'

describe '#RankRequest' do
  let(:player) { Player.new }
  let(:opponent) { Player.new }
  let(:rank) { "ace" }
  let(:rank_request) { RankRequest.new(player, opponent, rank) }
  let(:card_as) { Card.new(rank: "ace", suit: "spades") }
  let(:card_ah) { Card.new(rank: "ace", suit: "hearts") }

  before do
    player.add_card(card_as)
  end

  after do
    player.cards = []
    opponent.cards = []
    rank_request = RankRequest.new(player, opponent, rank)
  end

  it 'intializes with a player, opponent, and rank' do
    expect(rank_request.player).to eq player
    expect(rank_request.opponent).to eq opponent
    expect(rank_request.rank).to eq rank
  end

  it 'executes the request between players and returns true if it won cards' do
    opponent.add_card(card_ah)
    expect(rank_request.execute).to be true
  end

  it 'executes the request between players and returns false if it did not win cards' do
    expect(rank_request.execute).to be false
  end

  it 'makes sure the player collects their winnings' do
    opponent.add_card(card_ah)
    rank_request.execute
    expect(player.cards).to match_array [card_as, card_ah]
    expect(opponent.cards).to be_empty
  end

  it 'can tell you later if it did not win cards when executed' do
    rank_request.execute
    expect(rank_request.won_cards?).to be false
  end

  it 'can tell you later if it did win cards when executed' do
    opponent.add_card(card_ah)
    rank_request.execute
    expect(rank_request.won_cards?).to be true
  end

  it 'can tell you if it has already executed' do
    expect(rank_request.executed?).to be false
    rank_request.execute
    expect(rank_request.executed?).to be true
  end

  it 'only allows itself to execute once' do
    rank_request.execute
    opponent.add_card(card_ah)
    opponent_cards = opponent.cards
    player_cards = player.cards
    rank_request_details = rank_request.instance_variables
    rank_request.execute
    expect(opponent.cards).to eq opponent_cards
    expect(player.cards).to eq player_cards
    expect(rank_request.instance_variables).to eq rank_request_details
  end
end
