require_relative './game.rb'
require_relative './player.rb'

require_relative './user.rb'
require 'pry'
class Match
  attr_accessor :game, :users, :players, :over

  @@all = []

  def initialize(users = [], hand_size: 5)
    @users = users
    @users = [User.new, User.new] if @users.length < 2
    @players = []
    @users.each { |user| @players << Player.new(name: user.name) }
    icons = (Dir.glob("./public/images/players/*.png")).map! { |filename| filename = filename.sub(/^.\/public/,'') }
    @players.each_with_index { |player, index| player.icon = icons[index] }
    @game = Game.new(players: @players, hand_size: hand_size)
    @users.each { |user| user.add_match(self) }
    @over = false
    save
  end

  def save
    @@all << self
    @@all.uniq!
  end

  def num_players
    players.length
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

  def self.fake(num_players = 5)
    fake_users = [User.new(name: "Amanda"), User.new(name: "Vianney"), User.new(name: "Frederique"), User.new(name: "JeanLuc"), User.new(name: "Priscille")]
    users = fake_users[0...num_players]
    match = Match.new(users)
    match.save
    match
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

  def opponents(player)
    ordered_players = players.clone
    index = ordered_players.index(player)
    ordered_players.rotate!(index)
    ordered_players.shift
    ordered_players
  end

  def deck_count
    game.deck.count_cards
  end

  def player_from_name(name) # currently doesn't account for users with the same name
    @players.each { |player| return player if player.name == name }
    NullPlayer.new
  end

  def player_state(user)
    return {
      type: "player_state",
      player_cards: player(user).cards.to_json
    }
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

  def opponents(player)
    []
  end

  def players
    []
  end

  def deck_count
    0
  end

  def player_from_name(name)
  end

  def num_players
    0
  end

  def to_json
  end

  def ==(match)
    match.is_a? NullMatch
  end
end
