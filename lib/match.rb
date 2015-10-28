require_relative './game.rb'
require_relative './player.rb'

require_relative './user.rb'
require 'pry'
class Match
  attr_accessor :game, :users, :players, :over

  @@all = []

  def initialize(users = [], hand_size: 5)
    @users = users # possible to refactor these two lines into one?
    @users = [User.new, User.new] if @users.length < 2
    @players = []
    @users.each { |user| @players << Player.new(name: user.name) }
    @game = Game.new(players: @players, hand_size: hand_size)
    @users.each { |user| user.add_match(self) }
    save
    @over = false
  end

  def save
    @@all << self
    @@all.uniq!
  end

  def self.all
    @@all
  end

  def self.clear
    @@all = []
  end

  def self.find_by_obj_id(id)
    @@all.each { |match| return match if match.object_id == id }
    return nil
  end

  def user(player)
    user_index = @players.index(player)
    return @users[user_index] unless !user_index
    return NullUser.new
  end

  def player(user)
    player_index = @users.index(user)
    return @players[player_index] unless !player_index
    return NullPlayer.new
  end

  def player_from_name(name) # currently doesn't account for users with the same name
    @players.each { |player| return player if player.name == name }
    NullPlayer.new
  end

  def json_ready(user = nil)
    player = player(user) if user
    player_cards = []
    player.cards.each { |card| player_cards << card.to_s } if user
    return {
      type: "player_state",
      player: @players.index(player),
      player_cards: player_cards,
      match: self
    } if player
    return {
      type: "match_state",
      match: self
    }
  end

  def end_match
    @users.each { |user| user.end_current_match }
    @over = true
  end
end

class NullMatch
  attr_accessor :game

  def save
  end

  def user(player)
  end

  def player(user)
  end

  def users
    []
  end

  def players
    []
  end

  def player_from_name(name)
  end

  def to_json
  end

  def ==(match)
    match.is_a? NullMatch
  end
end
