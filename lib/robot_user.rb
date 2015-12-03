class RobotUser < User
  before_create :set_defaults

  def set_defaults
    self.name ||= User::FAKENAMES.rotate![0]
    self.think_time ||= 3
  end

  def make_play(match)
    @match = match
    if (match.game.next_turn.user_id == id && !match.over)
      contemplate_before { match.run_play(player, pick_opponent, pick_rank) }
    end
  end

  def player
    (@match || current_match).player(self)
  end

protected

  def opponents
    @match.opponents(player)
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


# Ken's Observer Spike code:
# def update(*args)
#   if (match.game.next_turn == player && !match.over)
#     make_request
#   end
# end
#
# def make_request
#   contemplate_before { match.run_play(player, pick_opponent, pick_rank) }
# end
#
# def player
#   @match.player(self)
# end
#
# protected
#
# def opponents
#   match.opponents(player)
# end
#
# def pick_opponent
#   opponents.sample
# end
#
# def pick_rank
#   player.cards.sample.rank
# end
#
# def contemplate_before
#   if think_time > 0
#     Thread.start do
#       sleep(think_time)
#       yield
#     end
#   else
#     yield
#   end
# end

# it 'makes a play if it is his turn' do
#   match.game.next_turn = user.player
#   match.changed
#   allow(match).to receive(:run_play).and_return(nil)
#   match.notify_observers
#   expect(match).to have_received(:run_play).with(user.player, any_args)
# end
