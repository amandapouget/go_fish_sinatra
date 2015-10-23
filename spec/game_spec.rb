require 'spec_helper'

describe Game do
  context 'game is initialized with two players' do
    let(:card_js) { Card.new(rank: "jack", suit: "spades") }
    let(:card_ad) { Card.new(rank: "ace", suit: "diamonds") }
    let(:card_ks) { Card.new(rank: "king", suit: "spades") }
    let(:card_kh) { Card.new(rank: "king", suit: "hearts") }
    let(:book) { [card_js, card_ad, card_ks, card_kh] }

    before do
      @player1 = Player.new(name: "Amanda")
      @player2 = Player.new(name: "Vianney")
      @game = Game.new(player1: @player1, player2: @player2)
    end

    describe '#initialize' do
      it 'creates a game with two players and a regular deck full of cards' do
        expect(@game.player1).to eq @player1
        expect(@game.player2).to eq @player2
        expect(@game.deck.type).to eq 'regular'
      end
    end

    describe '#deal' do
      it 'deals 5 cards to each player' do
        @game.deal
        expect(@player1.count_cards).to eq 5
        expect(@player2.count_cards).to eq 5
      end
    end

    describe '#winner' do
      it 'returns the player with the most number of books' do
        @player1.books << book
        expect(@game.winner).to eq @player1
      end

      it 'returns a nullplayer if the game has not started, is not over, or in the event of a tie' do
        expect(@game.winner).to eq NullPlayer.new
        @game.deal
        expect(@game.winner).to eq NullPlayer.new
        @player1.cards = []
        @player2.cards = []
        @player1.books << book
        @player2.books << book
        expect(@game.winner).to eq NullPlayer.new
      end
    end

    describe '#loser' do
      it 'returns the player who does not have the most books' do
        @player1.books << book
        expect(@game.loser).to eq @player2
      end

      it 'returns a nullplayer if the game has not started, is not over, or in the event of a tie' do
        expect(@game.loser).to eq NullPlayer.new
        @game.deal
        expect(@game.loser).to eq NullPlayer.new
        @player1.cards = []
        @player2.cards = []
        @player1.books << book
        @player2.books << book
        expect(@game.loser).to eq NullPlayer.new
      end
    end

    describe '#game_over?' do
      it 'returns false if both players and the deck still have cards' do
        @player1.add_card(card_kh)
        @player2.add_card(card_ks)
        expect(@game.game_over?).to be false
      end

      it 'returns true when one or more players or the deck are out of cards' do
        @player1.add_card(card_kh)
        expect(@game.game_over?).to be true
        @game.deck = []
        expect(@game.game_over?).to be true
      end
    end
  end
end
