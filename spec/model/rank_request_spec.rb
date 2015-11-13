require 'spec_helper'

describe '#RankRequest' do
  let(:rank) { "ace" }
  let(:rank_request) { build(:rank_request, rank: rank) }
  let(:player) { rank_request.player }
  let(:opponent) { rank_request.opponent }
  let(:card_as) { build(:card_as) }
  let(:card_ah) { build(:card_ah) }

  before do
    player.add_card(card_as)
  end

  after do
    player.cards = []
    opponent.cards = []
  end

  it 'can tell you its player, opponent, and rank' do
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
end
