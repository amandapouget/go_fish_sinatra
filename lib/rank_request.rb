require 'pry'

class RankRequest
  attr_accessor :player, :opponent, :rank

  def initialize(player, opponent, rank)
    @player = player
    @opponent = opponent
    @rank = rank
    @executed = false
  end

  def won_cards?
    @won_cards
  end

  def executed?
    @executed
  end

  def execute
    return nil if executed?
    @executed = true
    winnings = @player.request_cards(@opponent, @rank)
    winnings.empty? ? @won_cards = false : @won_cards = true
    player.collect_winnings(winnings)
    @won_cards
  end
end
