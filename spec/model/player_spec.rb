require 'spec_helper'

describe Player do
  describe '#initialize' do
    it 'creates a player object with a name, an icon, an array for holding cards, and an array for holding books' do
      player = Player.new(name: "John")
      expect(player.name).to eq "John"
      expect(player.cards).to eq []
      expect(player.books).to eq []
      expect(player.icon).to eq nil
    end

    it 'defaults to Anonymous if no name is given' do
      expect(Player.new.name).to eq "Anonymous"
    end
  end

  context 'player has cards' do
    let(:player) { build(:player) }
    let(:opponent) { build(:player) }
    let(:deck) { build(:deck) }
    cards = [:card_2c, :card_2d, :card_2h, :card_2s, :card_3h, :card_3c, :card_3d, :card_7h]
    cards.each { |card| let(card) { build(card) } }

    before do
      player.cards = [card_3h, card_2c, card_2d]
      opponent.cards = [card_3d, card_3c, card_7h]
      deck.cards << build(:card_2h)
    end

    def check_sorted
      value = 0
      player.cards do |card|
        expect(card.rank_value).to be >= value
        value = card.rank_value
      end
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
        expect(player.cards).to match_array [card_3h]
      end
    end

    describe '#request_cards' do
      it 'asks another player to return cards of a given rank' do
        expect(player.request_cards(opponent, "three")).to match_array [card_3c, card_3d]
      end

      it 'returns an empty array if not given a proper player in the argument' do
        expect(player.request_cards("Friend", "three")).to eq []
      end

      it 'returns an empty array if the requester does not have a card of that rank themselves' do
        expect(player.request_cards(opponent, "seven")).to eq []
      end

      it 'returns an empty array if the opponent does not have the rank requested' do
        expect(player.request_cards(opponent, "two")).to eq []
      end
    end

    describe '#collect_winnings' do
      it 'collects all the winnings from a particular play and adds the cards to the players cards' do
        player.collect_winnings([card_3c, card_3d])
        expect(player.cards).to include card_3c
        expect(player.cards).to include card_3d
      end

      it 'politely sorts the players cards by rank for easy visualization' do
        player.collect_winnings([])
        check_sorted
      end

      it 'makes any possible books and moves those cards to the players books' do
        player.collect_winnings([card_2s, card_2h])
        expect(player.books[0]).to match_array [card_2h, card_2c, card_2d, card_2s]
      end
    end

    describe '#go_fish' do
      it 'takes a card from the deck, adds it to the players cards and returns it' do
        go_fish_card = deck.cards[0]
        expect(player.go_fish(deck)).to eq go_fish_card
        expect(player.cards).to include go_fish_card
        expect(deck.cards).not_to include go_fish_card
      end

      it 'politely sorts the players cards' do
        player.go_fish(deck)
        check_sorted
      end

      it 'makes any possible books and moves those cards to the players books' do
        player.add_card(card_2s)
        player.go_fish(deck)
        expect(player.books[0]).to match_array [card_2h, card_2c, card_2d, card_2s]
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
    let(:player) { build(:player) }
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
