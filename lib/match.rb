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

  def users
    [@user1, @user2]
  end

  def to_json
    {
      type: "match",
      player1: player1.name,
      player2: player2.name,
      player1_cards: player1.count_cards,
      player2_cards: player2.count_cards,
      winner: game.winner.name,
      loser: game.loser.name,
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
