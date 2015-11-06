require './lib/match.rb'

class User
  @@users = []
  attr_accessor :id, :matches, :current_match, :name, :client

  def initialize(name: "Anonymous", client: nil)
    @client = client
    @name = name
    @id = self.object_id
    @matches = []
    @current_match = nil
    save
  end

  def save
    @@users << self
    @@users.uniq!
  end

  def self.find(id, users_to_search = @@users )
    users_to_search.each { |user| return user if user.id == id }
    return nil
  end

  def add_match(match)
    @current_match = match.object_id
    @matches << match.object_id
    @matches.uniq!
  end

  def end_current_match
    @current_match = nil
  end

  def self.all
    @@users
  end

  def self.clear
    @@users = []
  end

  def match_in_progress?
    return false if @current_match == nil
    match = Match.find_by_obj_id(@current_match)
    return !match.over
  end
end

class NullUser
  attr_accessor :id, :matches, :current_match, :name, :client

  def initialize
    @matches = []
  end

  def end_current_match
  end

  def save
  end

  def add_match(match)
  end

  def current_match_in_progress?
  end

  def ==(nulluser)
    nulluser.is_a? NullUser
  end
end
