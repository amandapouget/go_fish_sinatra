require 'pusher'

class MatchClientNotifier
  attr_reader :match

  def initialize(match)
    @match = match
    match.add_observer(self)
  end

  def update(*args)
    push("game_play_channel_#{match.object_id}", 'refresh_event')
  end

  def push(channel, event)
    until clients_ready? do
      sleep(1)
    end
    Pusher.trigger(channel, event, { message: "reload page" } )
  end

  protected

  def clients_ready?
    @clients_ready ||= match.users.all? { |user| !user.respond_to?(:ready_to_play) or user.ready_to_play }
  end
end
