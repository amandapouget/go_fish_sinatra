require_relative 'game'
require_relative 'player'
require_relative 'user'

class Match < ActiveRecord::Base
  has_and_belongs_to_many :users
  serialize :game
  after_create :set_defaults, :save
  after_save :notify_observers

  FIRST_PROMPT = ", click card, player & me to request cards!"

  def set_defaults
    self.game ||= Game.new(players: self.users.map { |user| Player.new(name: user.name, user_id: user.id) }, hand_size: self.hand_size)
    self.message ||= game.next_turn.name + FIRST_PROMPT
  end

  def notify_observers
    match_client_notifier.after_save(self)
  end

  def match_client_notifier
    @match_client_notifier ||= MatchClientNotifier.new
  end

  def players
    game.players
  end

  def user(player)
    User.find_by_id(player.user_id) || NullUser.new
  end

  def player(user)
    players.find { |player| player.user_id == user.id } || NullPlayer.new
  end

  def opponents(player)
    players.clone.tap { |players| players.rotate!(players.index(player)).shift }
  end

  def player_from_name(name)
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
    if game.make_request(player, opponent, rank).won_cards?
      self.message += " got cards"
    else
      self.message += " went fish"
      self.message += " & got one" if rank == game.go_fish(player, rank).rank
    end
    end_match if game.game_over?
    over ? self.message += "! Game over! Winner: #{game.winner.name}" : self.message += "! It's #{game.next_turn.name}'s turn!"
    save
    game.next_turn.make_play(self) if game.next_turn.is_a?(RobotUser)
  end

  def end_match
    update_attributes(over: true)
  end
end
