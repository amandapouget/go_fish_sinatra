class MatchMaker
  def match(user, number_of_players)
    relevant_pending_users = pending_users[number_of_players]
    relevant_pending_users << user
    Match.create(users: relevant_pending_users.shift(number_of_players)) if (relevant_pending_users.length >= number_of_players)
  end

  def pending_users
    @pending_users ||= Hash.new {|hash, key| hash[key] = []}
  end
end
