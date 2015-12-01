require 'pusher'

class MatchClientNotifier # < ActiveRecord::Observer
  # observe :match
  def send_notice(match)
    Pusher.trigger("game_play_channel_#{match.id}", 'refresh_event', { message: "refresh thyself" })
  end
end
