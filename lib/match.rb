require_relative 'game'
require_relative 'player'
require_relative 'user'
require 'observer'

class Match
  include Observable

  attr_accessor :game, :users, :players, :over, :message
  FIRST_PROMPT = ", click card, player & me to request cards!"
  @@all = []

  def initialize(users = [], hand_size: 5)
    @users = users
    @users.each { |user| user.add_match(self) }
    @players = @users.map { |user| Player.new(name: user.name) }
    @game = Game.new(players: @players, hand_size: hand_size)
    @over = false
    @message = @players[0].name + FIRST_PROMPT
    save
  end

  def save
    (@@all << self).uniq!
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
    players.clone.tap { |players| players.rotate!(players.index(player)).shift }
  end

  def deck_count
    game.deck.count_cards
  end

  def player_from_name(name) # currently doesn't account for users with the same name
    @players.each { |player| return player if player.name == name }
    NullPlayer.new
  end

  def player_from_id(id)
    @players.each { |player| return player if player.object_id == id }
    NullPlayer.new
  end

  def view(player)
    return {
      type: "player_view",
      message: @message,
      player: player,
      player_cards: player.cards,
      player_books: player.books,
      opponents: opponents(player),
      scores: players.map { |player| [player.name, player.books.size] }.push(["Fish Left", game.deck.count_cards])
    }.to_json
  end

  def run_play(player, opponent, rank) # encapsulate the crap
    rank == "six" ? rank_word = "sixe" : rank_word = rank
    @message = "#{player.name} asked #{opponent.name} for #{rank_word}s &"
    if @game.make_request(player, opponent, rank).won_cards?
      @message += " got cards"
    else
      @message += " went fish"
      @message += " & got one" if rank == @game.go_fish(player, rank).rank
    end
    end_match if @game.game_over?
    over ? @message += "! Game over! Winner: #{@game.winner.name}" : @message += "! It's #{game.next_turn.name}'s turn!"
    changed; notify_observers
  end

  def end_match
    @users.each { |user| user.end_current_match }
    @over = true
  end
end
