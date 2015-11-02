require 'spec_helper'

describe Card do
  describe "#initialize" do
    it 'creates a card with a readable rank and suit and sets an image if possible' do
      my_card = Card.new(rank: "seven", suit: "clubs")
      expect(my_card.rank).to eq "seven"
      expect(my_card.suit).to eq "clubs"
      expect(my_card.icon).to eq "/images/cards/c7.png"
    end
  end

  context 'cards are already made' do
    let(:card_7h) { Card.new(rank: 'seven', suit: 'hearts') }
    let(:card_7h_dupl) { Card.new(rank: 'seven', suit: 'hearts') }
    let(:card_7s) { Card.new(rank: 'seven', suit: 'spades') }
    let(:card_ah) { Card.new(rank: 'ace', suit: 'hearts') }

    describe "#rank_value" do
      it 'returns the numeric value of the rank' do
        expect(card_7h.rank_value).to eq 7
      end

      it 'works for face cards' do
        expect(card_ah.rank_value).to eq 14
      end

      it 'returns zero for cards outside the deck naming scheme' do
        expect(Card.new(rank: 'coolness', suit: 'marie').rank_value).to eq 0
      end
    end

    describe '#==' do
      it 'returns true for any two cards of the same rank and suit' do
        expect(card_7h == card_7h_dupl).to be true
      end

      it 'returns false if suit is different' do
        expect(card_7h == card_7s).to be false
      end

      it 'returns false if rank is different' do
        expect(card_ah == card_7h).to be false
      end

      it 'returns false if both rank and suit are different' do
        expect(card_ah == card_7s).to be false
      end
    end

    describe '#to_s' do
      it 'returns the string value of the rank and suit of a card' do
        expect(card_7s.to_s).to eq "the seven of spades"
        expect(card_ah.to_s).to eq "the ace of hearts"
        expect(card_7h.to_s).to eq "the seven of hearts"
      end
    end

    describe '#to_json' do
      it 'returns hash of rank and suit' do
        expect(card_7s.to_json).to eq('{"rank":"seven","suit":"spades"}')
      end
    end

    describe '#as_json' do
      it 'returns hash of rank and suit' do
        expect(card_7s.as_json).to eq({rank: 'seven', suit: 'spades'})
      end
    end
  end
end
