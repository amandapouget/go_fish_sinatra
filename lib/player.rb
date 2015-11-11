require 'pry'

class Player

  attr_accessor :name, :cards, :books, :icon

  def initialize(name: "Anonymous")
    @name = name
    @cards = []
    @books = []
    @icon = nil
  end

  def give_cards(rank)
    cards_to_give = []
    @cards.each { |card| cards_to_give << card if card.rank == rank }
    @cards.reject! { |card| card.rank == rank }
    cards_to_give
  end

  def request_cards(player, rank)
    return [] unless player.is_a? Player
    valid = false
    @cards.each { |card| valid = true if card.rank == rank }
    return [] if !valid
    cards = player.give_cards(rank)
    cards
  end

  def collect_winnings(winnings)
    winnings.each { |card| add_card(card) }
    make_books
    sort_cards
  end

  def go_fish(deck)
    fish = deck.deal_next_card
    add_card(fish)
    make_books
    sort_cards
    fish
  end

  def sort_cards
    @cards = @cards.sort_by { |card| card.rank_value }
  end

  def make_books
    rank_totals = Hash.new(0)
    @cards.each { |card| rank_totals[card.rank] += 1 }
    ranks_to_book = []
    rank_totals.each { |rank_name, rank_total| ranks_to_book << rank_name if rank_total == 4 }
    ranks_to_book.each { |rank| @books << request_cards(self, rank) }
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
    @name = "none"
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

  def sort_cards
  end

  def ==(player)
    player.is_a? NullPlayer
  end
end
