require 'pusher'

class MatchClientNotifier
  attr_reader :match

  def initialize(match)
    @match = match
    match.add_observer(self)
  end

  def update(*args)
    push("game_play_channel_#{@match.id}", 'refresh_event')
  end

  def push(channel, event, message = "reload page")
    Pusher.trigger(channel, event, { message: message } )
  end
end
