require 'spec_helper'

describe Game do
  describe 'number of players allowed' do
    it 'automatically initializes with at least two players' do
      game = Game.new
      expect(game.players.length).to eq 2
    end

    it 'can be initialized with two to five players' do
      expect { Game.new([Player.new, Player.new]) }.to_not raise_exception
      expect { Game.new([Player.new, Player.new, Player.new])}.to_not raise_exception
      expect { Game.new([Player.new, Player.new, Player.new, Player.new])}.to_not raise_exception
      expect { Game.new([Player.new, Player.new, Player.new, Player.new, Player.new])}.to_not raise_exception
    end

    it 'cannot be initialized with more than five players' do
      expect { Game.new([Player.new, Player.new, Player.new, Player.new, Player.new, Player.new])}.to raise_error(ArgumentError)
    end
  end

  describe 'hand_size range allowed' do
    it 'defaults to 5 cards dealt per player but can be initialized to deal an alternate number' do
      game = Game.new([Player.new, Player.new], hand_size: 7)
      expect(game.hand_size).to eq 7
      game = Game.new([Player.new, Player.new])
      expect(game.hand_size).to eq 5
    end

    it 'requires a hand_size of at least 1' do
      expect { Game.new([Player.new, Player.new], hand_size: 0) }.to raise_error(ArgumentError)
    end

    it 'raises an error if the number of cards to be dealt is greater than allowable given the number of players' do
      expect { Game.new([Player.new, Player.new, Player.new], hand_size: 20) }.to raise_error(ArgumentError)
    end
  end

  context 'game is initialized with three players and default hand_size' do
    let(:card_ks) { Card.new(rank: "king", suit: "spades") }
    let(:card_kh) { Card.new(rank: "king", suit: "hearts") }
    let(:card_kd) { Card.new(rank: "king", suit: "diamonds") }
    let(:card_kc) { Card.new(rank: "king", suit: "clubs") }
    let(:book) { [card_ks, card_kh, card_kd, card_kc] }

    before do
      @player0 = Player.new(name: "Amanda")
      @player1 = Player.new(name: "Vianney")
      @player2 = Player.new(name: "Frederique")
      @game = Game.new([@player0, @player1, @player2])
    end

    describe '#initialize' do
      it 'creates a game with players accessible in the players list and a regular deck full of cards' do
        expect(@game.players[0]).to eq @player0
        expect(@game.players[1]).to eq @player1
        expect(@game.players[2]).to eq @player2
        expect(@game.deck.type).to eq 'regular'
        full_deck = (Deck.new(type: 'regular')).count_cards
        expect(@game.deck.count_cards).to eq full_deck
      end
    end

    describe '#deal' do
      it 'deals hand_size number of cards from the deck to each player' do
        deck_count = @game.deck.count_cards
        @game.deal
        expect(@game.players[0].count_cards).to eq @game.hand_size
        expect(@game.players[1].count_cards).to eq @game.hand_size
        expect(@game.players[2].count_cards).to eq @game.hand_size
        num_cards_dealt = @game.hand_size * @game.players.length
        expect(@game.deck.count_cards).to eq deck_count - num_cards_dealt
      end
    end

    describe '#winner' do
      it 'returns a nullplayer if the game has not started, is not over, or in the event of a tie' do
        expect(@game.winner).to eq NullPlayer.new
        @game.deal
        expect(@game.winner).to eq NullPlayer.new
        @game.players.each { |player| player.cards = [] }
        @game.players[0].books << book
        @game.players[1].books << book
        expect(@game.winner).to eq NullPlayer.new
      end

      it 'if game is over and is not a tie, returns the player with the most number of books' do
        expect(@game.game_over?).to be true
        @game.players[2].books << book
        @game.players[2].books << book
        @game.players[1].books << book
        expect(@game.winner).to eq @game.players[2]
      end
    end

    describe '#go_fish' do
      it 'makes a player go fish' do
        count = @game.players[1].count_cards
        expect(@game.go_fish(@game.players[1])).to be_a Card
        expect(@game.players[1].count_cards).to eq count + 1
      end
    end

    describe '#game_over?' do
      it 'returns false if all players and the deck still have cards' do
        @game.players.each { |player| player.add_card(card_ks) }
        expect(@game.game_over?).to be false
      end

      it 'returns true when one or more players are out of cards' do
        @game.players.each { |player| player.add_card(card_ks) }
        @game.players[0].cards = []
        expect(@game.game_over?).to be true
      end

      it 'returns true when the deck is out of cards' do
        @game.players.each { |player| player.add_card(card_ks) }
        @game.deck = []
        expect(@game.game_over?).to be true
      end
    end
  end
end
