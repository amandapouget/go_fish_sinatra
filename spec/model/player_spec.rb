require 'spec_helper'

describe Player do
  let(:player) { Player.new(name: "John") }
  let(:opponent) { Player.new(name: "Dragon") }

  describe '#initialize' do
    it 'creates a player object with a name, an icon, an array for holding cards, and an array for holding books' do
      expect(player.name).to eq "John"
      expect(player.cards).to eq []
      expect(player.books).to eq []
      expect(player.icon).to eq ""
    end

    it 'defaults to Anonymous if no name is given' do
      expect(Player.new.name).to eq "Anonymous"
    end
  end

  context 'player has cards' do
    let(:card_2c) { build(:card_2c) }
    let(:card_2d) { build(:card_2d) }
    let(:card_2h) { build(:card_2h) }
    let(:card_2s) { build(:card_2s) }
    let(:card_3h) { build(:card_3h) }
    let(:card_10d) { build(:card_10d) }
    let(:card_js) { build(:card_js) }
    let(:card_ah) { build(:card_ah) }
    let(:card_3c) { build(:card_3c) }
    let(:card_3d) { build(:card_3d) }
    let(:card_7h) { build(:card_7h) }

    before do
      player.cards = [card_2c, card_3h, card_js, card_ah, card_10d, card_2d]
      opponent.cards = [card_3c, card_3d, card_7h]
      @deck = build(:deck, type: 'regular')
      @deck.shuffle
    end

    describe '#give_cards' do
      it 'returns an array of cards with all the cards from the players cards that match the rank demanded' do
        expect(player.give_cards("two")).to match_array [card_2c, card_2d]
      end

      it 'returns an empty array if no such cards are found' do
        expect(player.give_cards("nine")).to match_array []
      end

      it 'removes the cards from the players hand' do
        player.give_cards("two")
        expect(player.cards).to match_array [card_3h, card_js, card_ah, card_10d]
      end
    end

    describe '#request_cards' do
      it 'asks another player to return cards of a given rank' do
        expect(player.request_cards(opponent, "three")).to eq [card_3c, card_3d]
      end

      it 'returns an empty array if not given a proper player in the argument' do
        expect(player.request_cards("Friend", "three")).to eq []
      end

      it 'returns an empty array if the requester does not have a card of that rank themselves' do
        expect(player.request_cards(opponent, "seven")).to eq []
      end

      it 'returns an empty array if the opponent does not have the rank requested' do
        expect(player.request_cards(opponent, "ace")).to eq []
      end
    end

    describe '#collect_winnings' do
      it 'collects all the winnings from a particular play and adds the cards to the players cards' do
        player.collect_winnings([card_3c, card_7h])
        expect(player.cards).to include card_3c
        expect(player.cards).to include card_7h
      end

      it 'politely sorts the players cards by rank for easy visualization' do
        player.collect_winnings([])
        value = 0
        player.cards { |card|
          expect(card.rank_value).to be >= value
          value = card.rank_value }
      end

      it 'makes any possible books and moves those cards to the players books' do
        player.collect_winnings([card_2s, card_2h])
        expect(player.books[0]).to match_array [card_2h, card_2c, card_2d, card_2s]
      end
    end

    describe '#go_fish' do
      it 'takes a card from the deck and adds it to the players cards' do
        deck_count = @deck.count_cards
        player_count = player.count_cards
        player.go_fish(@deck)
        expect(player.count_cards).to eq player_count + 1
        expect(@deck.count_cards).to eq deck_count - 1
      end

      it 'politely sorts the players cards' do
        player.go_fish(@deck)
        value = 0
        player.cards { |card|
          expect(card.rank_value).to be >= value
          value = card.rank_value }
      end

      it 'makes any possible books and moves those cards to the players books' do
        @deck.cards[0] = card_2h
        player.add_card(card_2s)
        player.go_fish(@deck)
        expect(player.books[0]).to match_array [card_2h, card_2c, card_2d, card_2s]
      end

      it 'returns the card fished' do
        card_to_fish = @deck.cards[0]
        expect(player.go_fish(@deck)).to eq card_to_fish
      end
    end

    describe '#add_card' do
      it 'adds a card to the players cards at the bottom' do
        player.add_card(card_7h)
        added_card = player.cards.last
        expect(added_card).to eq card_7h
      end
    end

    describe '#count_cards' do
      it 'returns the number of cards a player has' do
        expect(player.count_cards).to eq player.cards.length
      end
    end

    describe '#out_of_cards?' do
      it 'returns false when the player still has cards' do
        expect(player.out_of_cards?).to be false
      end
      it 'returns true when the player has no more cards' do
        player.cards = []
        expect(player.out_of_cards?).to be true
      end
    end
  end

  describe NullPlayer do
    let(:nullplayer) { NullPlayer.new }
    let(:card_3c) { build(:card_3c) }
    let(:deck) { build(:deck, type: 'regular') }

    it 'returns none when its name is called' do
      expect(nullplayer.name).to eq "none"
    end

    it 'returns an empty array when its cards are called' do
      expect(nullplayer.cards).to eq []
    end

    it 'does not raise an exception when the regular player methods are called' do
      expect { nullplayer.give_cards("two") }.to_not raise_exception
      expect { nullplayer.request_cards(player, "ten") }.to_not raise_exception
      expect { nullplayer.collect_winnings([card_3c]) }.to_not raise_exception
      expect { nullplayer.go_fish(deck) }.to_not raise_exception
      expect { nullplayer.add_card(card_3c) }.to_not raise_exception
      expect { nullplayer.make_books }.to_not raise_exception
      expect { nullplayer.sort_cards }.to_not raise_exception
      expect { nullplayer.icon }.to_not raise_exception
    end

    it 'returns 0 when its cards are counted' do
      expect(nullplayer.count_cards).to eq 0
    end

    it 'returns true when asked if it is out of cards' do
      expect(nullplayer.out_of_cards?).to be true
    end

    it 'calls all nullplayer objects equal if comparing two nullplayers' do
      expect(NullPlayer.new == NullPlayer.new).to be true
    end

    it 'returns false if comparing the equality of a nullplayer with a player' do
      expect(NullPlayer.new == Player.new).to be false
    end
  end
end
