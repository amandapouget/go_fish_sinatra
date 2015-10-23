require './lib/game.rb'
require './lib/player.rb'

class Match
  attr_accessor :game, :player1, :player2, :user1, :user2

  def initialize(game: Game.new, user1: User.new, user2: User.new)
    @game = game
    @user1 = user1
    @user2 = user2
    @player1 = game.player1
    @player2 = game.player2
    user1.add_match(self)
    user2.add_match(self)
    @users = [@user1, @user2]
  end

  def user(player)
    return @user1 if player == player1
    return @user2 if player == player2
  end

  def player(user)
    return @player1 if user == user1
    return @player2 if user == user2
  end

  def opponent(user)
    return @user1 if user == @user2
    return @user2 if user == @user1
  end

  def player_from_name(name)
    return @player1 if @player1.name == name
    return @player2 if @player2.name == name
    NullPlayer.new
  end

  def users
    [@user1, @user2]
  end

  def to_json(user = nil)
    player = player(user) if user
    player1_cards = []
    player1.cards.each { |card| player1_cards << card.to_s }
    player2_cards = []
    player2.cards.each { |card| player2_cards << card.to_s }
    return {
      type: "match_state",
      player1: user1.name,
      player2: user2.name,
      player1_cards: player1_cards,
      player2_cards: player2_cards,
      player1_num_cards: player1.count_cards,
      player2_num_cards: player2.count_cards,
      player1_num_books: player1.books.length,
      player2_num_books: player2.books.length,
      player1_books: player1.books,
      player2_books: player2.books,
      deck_num_cards: game.deck.count_cards,
      game_over?: game.game_over?,
      winner: game.winner.name,
      loser: game.loser.name
    } unless player
    player_cards = []
    player.cards.each { |card| player_cards << card.to_s }
    return {
      type: "player_state",
      player: user(player).name,
      player_cards: player_cards,
      player_num_cards: player.count_cards,
      player_num_books: player.books.length,
      player_books: player.books,
      game_over?: game.game_over?
    }
  end

  def end_match
    @user1.end_current_match if @user1.current_match == self
    @user2.end_current_match if @user2.current_match == self
  end
end

class NullMatch
  attr_accessor :game, :player1, :player2, :user1, :user2

  def user(player)
  end

  def player(user)
  end

  def users
    []
  end

  def to_json
  end

  def ==(match)
    match.is_a? NullMatch
  end
end
