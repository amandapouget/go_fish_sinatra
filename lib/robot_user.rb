class RobotUser
  attr_reader :match, :think_time, :name

  def initialize(think_time = 2.5)
    @think_time = think_time
    @name = FAKENAMES.rotate![0]
  end

  def add_match(match)
    @match = match
    match.add_observer(self)
  end

  def update(*args)
    if (match.game.next_turn == player && !match.over)
      make_request
    end
  end

  def make_request
    contemplate_before { match.run_play(player, pick_opponent, pick_rank) }
  end

  def player
    match.player(self)
  end

  def end_current_match
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
