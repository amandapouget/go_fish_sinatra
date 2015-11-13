require 'spec_helper'

describe Deck do
  let(:deck) { build(:deck, :with_cards) }

  describe '#initialize' do
    it 'creates a deck with a card collection' do
      deck = Deck.new()
      expect(deck.cards).to eq []
    end
  end

  describe 'autofilled deck' do
    it 'can create a prefilled deck via the class of cards the deck will hold' do
      deck_with_cards = Card.deck
      expect(deck_with_cards).to be_a Deck
      expect(deck.cards).not_to be_empty
    end
  end

  describe '#shuffle' do
    it 'reorders the cards in a different way each time' do
      my_unshuffled_deck = build(:deck, :with_cards)
      expect(deck.cards == my_unshuffled_deck.cards).to be true
      deck.shuffle
      expect(deck.cards == my_unshuffled_deck.cards).to be false
    end
  end

  describe '#count_cards' do
    it 'returns a count of how many cards are in the deck' do
      expect(deck.count_cards).to eq deck.cards.length
    end
  end

  describe '#deal_next_card' do
    it 'returns the top card in the deck' do
      card_to_deal = deck.cards[0]
      expect(card_to_deal == deck.deal_next_card).to be true
    end
    it 'removes that card from the deck' do
      count = deck.count_cards
      card_to_deal = deck.deal_next_card
      expect(deck.count_cards).to eq count - 1
      expect(deck.cards.include?(card_to_deal)).to be false
    end
  end

  describe '#empty?' do
    it 'returns true if all the cards have been dealt' do
      deck.cards.length.times { deck.deal_next_card }
      expect(deck.empty?).to be true
    end
    it 'returns false if it still has cards' do
      expect(deck.empty?).to be false
    end
  end

  describe '#to_json' do
    it 'returns a json version of the deck, including json versions of the cards within it' do
      deck_with_1_card = build(:deck, cards: [:card] )
      card = deck_with_1_card.cards[0]
      expect(deck_with_1_card.to_json).to eq "{\"cards\":[{\"rank\":\"#{card.rank}\",\"suit\":\"#{card.suit}\",\"icon\":\"#{card.icon}\"}]}"
    end
  end
end
