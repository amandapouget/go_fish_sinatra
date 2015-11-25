require_relative 'game'
require_relative 'player'
require_relative 'user'
require 'observer'

class Match < ActiveRecord::Base
  # include Observable

  has_and_belongs_to_many :users
  serialize :game_info
  after_initialize :set_first_message

  FIRST_PROMPT = ", click card, player & me to request cards!"

  def set_first_message
    self.message = players[0].name + FIRST_PROMPT
    save
  end

  def players
    game.players
  end

  def game
    @game ||= self.game_info = Game.new(players: players = self.users.map { |user| Player.new(name: user.name) }, hand_size: self.hand_size)
  end

  def user(player)
    players.include?(player) ? users[players.index(player)] : NullUser.new
  end

  def player(user)
    users.include?(user) ? players[users.index(user)] : NullPlayer.new
  end

  def opponents(player)
    players.clone.tap { |players| players.rotate!(players.index(player)).shift }
  end

  def deck_count
    game.deck.count_cards
  end

  def player_from_name(name) # currently doesn't account for users with the same name
    return players.find { |player| player.name == name } || NullPlayer.new
  end

  def view(player)
    return {
      message: self.message,
      player: player,
      player_index: players.index(player),
      opponents: opponents(player).map { |opponent| {index: players.index(opponent), name: opponent.name, icon: opponent.icon} },
      scores: players.map { |player| [player.name, player.books.size] }.push(["Fish Left", game.deck.count_cards])
    }.to_json
  end

  def run_play(player, opponent, rank) # encapsulate the crap
    rank == "six" ? rank_word = "sixe" : rank_word = rank
    self.message = "#{player.name} asked #{opponent.name} for #{rank_word}s &"
    if @game.make_request(player, opponent, rank).won_cards?
      self.message += " got cards"
    else
      self.message += " went fish"
      self.message += " & got one" if rank == @game.go_fish(player, rank).rank
    end
    end_match if @game.game_over?
    over ? self.message += "! Game over! Winner: #{@game.winner.name}" : self.message += "! It's #{game.next_turn.name}'s turn!"
    save
    # changed; notify_observers
  end


  def end_match
    update_attributes(over: true)
  end
end
