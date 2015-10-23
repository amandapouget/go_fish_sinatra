class Player

  attr_accessor :name, :cards, :books

  def initialize(name: "Anonymous")
    @name = name
    @cards = []
    @books = []
  end

  def give_cards(rank)
    cards_to_give = []
    @cards.each { |card| cards_to_give << card if card.rank == rank }
    @cards.reject! { |card| card.rank == rank }
    cards_to_give
  end

  def request_cards(player, rank)
    valid = false
    @cards.each { |card| valid = true if card.rank == rank }
    return [] if !valid
    player.give_cards(rank)
  end

  def collect_winnings(cards)
    cards.each do |card|
      add_card(card)
    end
  end

  def go_fish(deck)
    add_card(deck.deal_next_card)
  end

  def make_books
    rank_totals = Hash.new(0)
    cards.each { |card| rank_totals[card.rank] += 1 }
    ranks_to_book = []
    rank_totals.each { |rank_total, rank_name| ranks_to_book << rank if rank_total == 4 }
    ranks_to_book.each { @books << request_cards(self, rank) }
  end

  def add_card(card)
    @cards << card
  end

  def count_cards
    @cards.length
  end

  def out_of_cards?
    @cards==[]
  end
end

class NullPlayer < Player
  attr_accessor :name, :cards, :books

  def initialize
    @name = nil
    @cards = []
    @books = []
  end

  def give_cards(rank)
  end

  def request_cards(player, rank)
  end

  def collect_winnings(cards)
  end

  def go_fish(deck)
  end

  def add_card(card)
  end

  def make_books
  end

  def ==(player)
    player.is_a? NullPlayer
  end
end
