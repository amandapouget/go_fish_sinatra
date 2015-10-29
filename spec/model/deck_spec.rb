require 'spec_helper'

describe Deck do
  describe '#initialize' do
    it "creates a deck with a type and a card collection" do
      my_deck = Deck.new()
      expect(my_deck.type).to eq 'none'
      expect(my_deck.cards).to eq []
    end

    it "when passed the type 'regular', has four cards of every rank, thirteen cards of every suit, and no two equal cards" do
      my_deck = Deck.new(type: 'regular')
      rank_totals = Hash.new(0)
      suit_totals = Hash.new(0)
      my_deck.cards.each do |card|
        rank_totals[card.rank] += 1
        suit_totals[card.suit] += 1
      end
      rank_totals.values.each { |rank_total| expect(rank_total).to eq 4 }
      suit_totals.values.each { |suit_total| expect(suit_total).to eq 13 }
      expect(my_deck.cards.uniq).to eq(my_deck.cards)
    end
  end

  context 'regular deck type already created' do
    let(:my_deck) { Deck.new(type: 'regular') }

    describe '#shuffle' do
      it 'reorders the cards in a different way each time' do
        my_unshuffled_deck = Deck.new(type: 'regular')
        expect(my_deck.cards == my_unshuffled_deck.cards).to be true
        my_deck.shuffle
        expect(my_deck.cards == my_unshuffled_deck.cards).to be false
      end
    end

    describe '#count_cards' do
      it 'returns a count of how many cards are in the deck' do
        expect(my_deck.count_cards).to eq 52
        my_deck.deal_next_card
        expect(my_deck.count_cards).to eq 51
      end
    end

    describe '#deal_next_card' do
      it 'returns the top card in the deck' do
        my_card = my_deck.cards[0]
        expect(my_card == my_deck.deal_next_card).to be true
      end
      it 'removes that card from the deck' do
        count = my_deck.count_cards
        my_deck.deal_next_card
        expect(my_deck.count_cards).to eq count - 1
      end
    end

    describe '#empty?' do
      it 'returns true if all the cards have been dealt' do
        my_deck.count_cards.times { my_deck.deal_next_card }
        expect(my_deck.empty?).to be true
      end
      it 'returns false if it still has cards' do
        expect(my_deck.empty?).to be false
      end
    end

    describe '#add_card' do
      it 'adds a card to the bottom of the deck' do
        count = my_deck.count_cards
        my_card = Card.new(rank: "three", suit: "spades")
        my_deck.add_card(my_card)
        expect(my_deck.cards[count]).to eq my_card
      end
      it 'increases the deck count by 1' do
        count = my_deck.count_cards
        my_card = Card.new(rank: "three", suit: "spades")
        my_deck.add_card(my_card)
        expect(my_deck.count_cards).to eq count + 1
      end
    end
  end
end
