require 'spec_helper'

describe Game do
  let(:players) { Array.new(MAX_PLAYERS + 1) { build(:player) } }

  describe 'number of players allowed' do
    it "automatically initializes with at least #{MIN_PLAYERS} players" do
      game = Game.new
      expect(game.players.length).to eq MIN_PLAYERS
    end

    it "can be initialized with up to #{MAX_PLAYERS} players" do
      (MAX_PLAYERS - MIN_PLAYERS).times { |num_players| expect { Game.new(players: players[0..num_players + 1]) }.to_not raise_exception }
    end

    it "cannot be initialized with more than #{MAX_PLAYERS} players" do
      expect { Game.new(players: players[0..MAX_PLAYERS]) }.to raise_error(ArgumentError)
    end
  end

  describe 'hand_size range allowed' do
    it 'defaults to 5 cards dealt per player but can be initialized to deal an alternate number' do
      game = Game.new(hand_size: 7)
      expect(game.hand_size).to eq 7
      game = Game.new
      expect(game.hand_size).to eq 5
    end

    it 'requires a hand_size of at least 1' do
      expect { Game.new(hand_size: 0) }.to raise_error(ArgumentError)
    end

    it 'raises an error if the number of cards to be dealt is greater than allowable given the number of players' do
      deck_length = build(:deck, type: 'regular').count_cards
      expect { Game.new(players: players[0..1], hand_size: deck_length) }.to raise_error(ArgumentError)
    end
  end

  context 'game is initialized with two players and default hand_size' do
    let(:card_ks) { build(:card_ks) }
    let(:card_kh) { build(:card_kh) }
    let(:card_kd) { build(:card_kd) }
    let(:card_kc) { build(:card_kc) }
    let(:book) { [card_ks, card_kh, card_kd, card_kc] }
    let(:player0) { build(:player) }
    let(:player1) { build(:player) }
    let(:game) { Game.new(players: [player0, player1]) }

    after do
      player0.cards = []
      player1.cards = []
      game.deck = build(:deck, type: 'regular')
      game.requests = []
    end

    describe '#initialize' do
      it 'creates a game with players accessible in the players list, a regular deck full of cards, an array of player requests that have been made' do
        expect(game.players).to match_array [player0, player1]
        expect(game.deck.type).to eq 'regular'
        full_deck_length = build(:deck, type: 'regular').count_cards
        expect(game.deck.count_cards).to eq full_deck_length
        expect(game.requests).to eq []
      end
    end

    describe '#deal' do
      it 'deals hand_size number of cards from the deck to each player' do
        deck_count = game.deck.count_cards
        game.deal
        expect(player0.count_cards).to eq game.hand_size
        expect(player1.count_cards).to eq game.hand_size
        num_cards_dealt = game.hand_size * game.players.length
        expect(game.deck.count_cards).to eq deck_count - num_cards_dealt
      end
    end

    describe '#winner' do
      it 'returns a nullplayer if the game has not started, is not over, or in the event of a tie' do
        expect(game.winner).to eq NullPlayer.new
        game.deal
        expect(game.winner).to eq NullPlayer.new
        game.players.each { |player| player.cards = [] }
        player0.books << book
        player1.books << book
        expect(game.winner).to eq NullPlayer.new
      end

      it 'if game is over and is not a tie, returns the player with the most number of books' do
        expect(game.game_over?).to be true
        player1.books << book
        expect(game.winner).to eq player1
      end
    end

    describe '#go_fish' do
      it 'makes a player go fish' do
        count = player1.count_cards
        expect(game.go_fish(player1, "any_rank")).to be_a Card
        expect(player1.count_cards).to eq count + 1
      end

      it 'advances turn unless the player wins the right fish' do
        rank_wanted = game.deck.cards[0].rank
        player = game.next_turn
        game.go_fish(player, rank_wanted)
        expect(game.next_turn).to eq player
        next_player = game.players[(game.players.index(player) + 1) % game.players.length]
        game.go_fish(player, "rank_not_found")
        expect(game.next_turn).to eq next_player
      end
    end

    describe'#make_request' do
      it 'executes a request between two players, adds the request to the requests array, and returns the request' do
        player0.cards = [card_ks]
        player1.cards = [card_kd]
        rank_request = game.make_request(player0, player1, "king")
        expect(rank_request.player).to eq player0
        expect(rank_request.opponent).to eq player1
        expect(rank_request.won_cards?).to be true
        expect(rank_request.executed?).to be true
        expect(player0.cards).to match_array [card_ks, card_kd]
        expect(player1.cards).to match_array []
        expect(game.requests).to match_array [rank_request]
      end
    end

    describe '#game_over?' do
      it 'returns false if all players and the deck still have cards' do
        game.players.each { |player| player.add_card(card_ks) }
        expect(game.game_over?).to be false
      end

      it 'returns true when one or more players are out of cards' do
        player1.cards = [card_ks]
        player0.cards = []
        expect(game.game_over?).to be true
      end

      it 'returns true when the deck is out of cards' do
        game.players.each { |player| player.add_card(card_ks) }
        game.deck = []
        expect(game.game_over?).to be true
      end
    end
  end
end
