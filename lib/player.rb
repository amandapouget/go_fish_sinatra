class Player
  attr_accessor :name, :cards, :books, :icon

  @@icons = Dir.glob("./public/images/players/*.png")

  def initialize(name: "Anonymous")
    @name = name
    @cards = []
    @books = []
    @icon = set_icon
  end

  def set_icon
    @@icons.rotate![0].sub(/^.\/public/,'')
  end

  def give_cards(rank)
    cards_to_give, @cards = @cards.partition { |card| card.rank == rank }
    cards_to_give
  end

  def request_cards(player, rank)
    valid = @cards.any? { |card| card.rank == rank }
    return [] unless valid && player.is_a?(Player)
    player.give_cards(rank)
  end

  def collect_winnings(winnings)
    winnings.each { |card| add_card(card) }
    make_books_and_sort_cards
  end

  def go_fish(deck)
    fish = deck.deal_next_card
    add_card(fish)
    make_books_and_sort_cards
    fish
  end

  def add_card(card)
    @cards << card
  end

  def count_cards
    @cards.size
  end

  def out_of_cards?
    @cards==[]
  end

  def to_json(*args)
    hash = { name: name, icon: icon }.to_json(*args)
  end
end

private
  def make_books_and_sort_cards
    rank_totals = Hash.new(0)
    @cards.each { |card| rank_totals[card.rank] += 1 }
    rank_totals.each { |rank_name, rank_total|  @books << request_cards(self, rank_name) if rank_total == 4 }
    @cards = @cards.sort_by { |card| card.rank_value }
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

  def eql?(player)
    player.is_a? NullPlayer
  end

  alias == eql?

  def hash
    name.hash
  end
end
