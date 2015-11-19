FAKENAMES = ["Marie", "Amanda", "Bob", "Charlie", "David", "Echo", "Frank", "Gertrude", "Helga", "Iggy", "Jaqueline", "Kevin", "Lillian"]

class User
  @@all = []
  attr_accessor :matches, :current_match, :name, :client, :ready_to_play

  def initialize(name: "Anonymous", client: nil)
    @client = client
    @name = name
    @matches = []
    @current_match = nil
    save
  end

  def self.find(id, users_to_search = @@all )
    users_to_search.each { |user| return user if user.object_id == id }
    return nil
  end

  def add_match(match)
    @current_match = match.object_id
    (@matches << match.object_id).uniq!
  end

  def end_current_match
    @current_match = nil
  end

  def self.clear
    @@all = []
  end

private
  def save
    @@all << self
    @@all.uniq!
  end
end

class NullUser
  attr_accessor :matches, :current_match, :name, :client

  def initialize
    @matches = []
  end

  def end_current_match
  end

  def save
  end

  def add_match(match)
  end

  def eql?(nulluser)
    nulluser.is_a? NullUser
  end

  alias == eql?

  def hash
    "hash".hash
  end
end
