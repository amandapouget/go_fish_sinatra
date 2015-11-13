require_relative 'game'
require_relative 'player'
require_relative 'user'

class Match
  attr_accessor :game, :users, :players, :over, :message

  @@all = []

  def initialize(users = [], hand_size: 5)
    @users = users
    @users.each { |user| user.add_match(self) }
    @players = @users.map { |user| Player.new(name: user.name) }
    add_icons(@players)
    @game = Game.new(players: @players, hand_size: hand_size)
    @over = false
    @message = "#{@players[0].name}, click card, player & me to request cards!"
    save
  end

  def add_icons(players)
    icons = Dir.glob("./public/images/players/*.png")
    players.each_with_index { |player, index| player.icon = icons[index].sub(/^.\/public/,'') }
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

  def self.find(id)
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

  def player_from_object_id(id)
    @players.each { |player| return player if player.object_id == id }
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

  def run_play(player, opponent, rank)
    rank_request = @game.make_request(player, opponent, rank)
    rank == "six" ? rank_word = "sixe" : rank_word = rank
    @message = "#{player.name} asked #{opponent.name} for #{rank_word}s &"
    if rank_request.won_cards?
      @message += " got cards"
    else
      fish_card = @game.go_fish(player, rank)
      @message += " went fish"
      @message += " & got one" if fish_card.rank == rank
    end
    end_match if @game.game_over?
    over ? @message += "! Game over! Winner: #{@game.winner.name}" : @message += "! It's #{game.next_turn.name}'s turn!"
  end

  def end_match
    @users.each { |user| user.end_current_match }
    @over = true
  end
end
