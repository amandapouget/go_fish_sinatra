require_relative 'game'
require_relative 'player'
require_relative 'user'

class Match < ActiveRecord::Base
  has_and_belongs_to_many :users
  serialize :game
  after_create :set_defaults, :save

  FIRST_PROMPT = ", click card, player & me to request cards!"

  def set_defaults
    self.game ||= Game.new(players: self.users.map { |user| Player.new(name: user.name, user_id: user.id) }, hand_size: self.hand_size)
    self.game.next_turn = game.players.find { |player| user(player).is_a? RealUser } if game.requests.length == 0
    self.message ||= game.next_turn.name + FIRST_PROMPT
  end

  def notify_observers
    match_client_notifier.send_notice(self)
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
    players.clone.tap { |players| players.rotate!(players.index{ |available_player| available_player.user_id == player.user_id}).shift }
  end

  def player_from_name(name)
    return players.find { |player| player.name == name } || NullPlayer.new
  end

  def view(player)
    return {
      message: self.message,
      player: player,
      player_index: players.index(player),
      opponents: opponents(player).map { |opponent| {user_id: opponent.user_id, name: opponent.name, icon: opponent.icon} },
      scores: players.map { |player| [player.name, player.books.size] }.push(["Fish Left", game.deck.count_cards])
    }.to_json
  end

  def run_play(player, opponent, rank) # encapsulate the crap
    if game.next_turn.user_id == player.user_id
      rank == "six" ? rank_word = "sixe" : rank_word = rank
      self.message = "#{player.name} asked #{opponent.name} for #{rank_word}s &"
      if game.make_request(player, opponent, rank).won_cards?
        self.message += " got cards"
      else
        self.message += " went fish"
        self.message += " & got one" if rank == game.go_fish(player, rank).rank
      end
      if game.game_over?
        end_match
        self.message += "! Game over! Winner: #{game.winner.name}"
      else
        self.message += "! It's #{game.next_turn.name}'s turn!"
      end
      save
      notify_observers
      next_user = user(game.next_turn)
      next_user.make_play(self) if next_user.is_a?(RobotUser) && !game.game_over?
    end
  end

  def end_match
    update_column(:over, true)
  end
end
