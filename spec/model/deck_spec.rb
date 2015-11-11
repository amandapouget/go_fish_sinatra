require 'spec_helper'

describe Deck do
  describe '#initialize' do
    it "creates a deck with a type and a card collection" do
      deck = Deck.new()
      expect(deck.type).to eq 'none'
      expect(deck.cards).to eq []
    end

    it "when passed the type 'regular', has four cards of every rank, thirteen cards of every suit, and no two equal cards" do
      deck = Deck.new(type: 'regular')
      rank_totals = Hash.new(0)
      suit_totals = Hash.new(0)
      deck.cards.each do |card|
        rank_totals[card.rank] += 1
        suit_totals[card.suit] += 1
      end
      rank_totals.values.each { |rank_total| expect(rank_total).to eq 4 }
      suit_totals.values.each { |suit_total| expect(suit_total).to eq 13 }
      expect(deck.cards.uniq).to eq(deck.cards)
    end
  end

  context 'regular deck type already created' do
    let(:deck) { Deck.new(type: 'regular') }
    let(:card) { build(:card_3s) }

    describe '#shuffle' do
      it 'reorders the cards in a different way each time' do
        my_unshuffled_deck = Deck.new(type: 'regular')
        expect(deck.cards == my_unshuffled_deck.cards).to be true
        deck.shuffle
        expect(deck.cards == my_unshuffled_deck.cards).to be false
      end
    end

    describe '#count_cards' do
      it 'returns a count of how many cards are in the deck' do
        expect(deck.count_cards).to eq 52
        deck.deal_next_card
        expect(deck.count_cards).to eq 51
      end
    end

    describe '#deal_next_card' do
      it 'returns the top card in the deck' do
        card = deck.cards[0]
        expect(card == deck.deal_next_card).to be true
      end
      it 'removes that card from the deck' do
        count = deck.count_cards
        deck.deal_next_card
        expect(deck.count_cards).to eq count - 1
      end
    end

    describe '#empty?' do
      it 'returns true if all the cards have been dealt' do
        deck.count_cards.times { deck.deal_next_card }
        expect(deck.empty?).to be true
      end
      it 'returns false if it still has cards' do
        expect(deck.empty?).to be false
      end
    end

    describe '#add_card' do
      it 'adds a card to the bottom of the deck' do
        count = deck.count_cards
        deck.add_card(card)
        expect(deck.cards[count]).to eq card
      end
      it 'increases the deck count by 1' do
        count = deck.count_cards
        deck.add_card(card)
        expect(deck.count_cards).to eq count + 1
      end
    end

    describe '#to_json' do
      it 'returns a json version of the deck, including json versions of the cards within it' do
        deck_with_1_card = Deck.new
        deck_with_1_card.add_card(card)
        expect(deck_with_1_card.to_json).to eq "{\"type\":\"none\",\"cards\":[{\"rank\":\"three\",\"suit\":\"spades\"}]}"
      end
    end
  end
end
