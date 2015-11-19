class RobotUser
  attr_reader :match, :think_time

  def initialize(think_time = 0)
    @think_time = think_time
  end

  def add_match(match)
    @match = match
    match.add_observer(self)
  end

  def name
    'robot'
  end

  def update(*args)
    if (match.game.next_turn == player)
      make_request
    end
  end

  def make_request
    contemplate_before { match.run_play(player, pick_opponent, pick_rank) }
  end

  def player
    match.player(self)
  end

  protected

  def opponents
    match.opponents(player)
  end

  def pick_opponent
    opponents.sample
  end

  def pick_rank
    player.cards.sample.rank
  end

  def contemplate_before
    if think_time > 0
      Thread.start do
        sleep(think_time)
        yield
      end
    else
      yield
    end
  end
end
