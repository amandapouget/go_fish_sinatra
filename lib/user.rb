class User < ActiveRecord::Base
  FAKENAMES = ["Marie", "Amanda", "Bob", "Charlie", "David", "Echo", "Frank", "Gertrude", "Helga", "Iggy", "Jaqueline", "Kevin", "Lillian", "Mike", "Naomi", "Olivier", "Patrick", "Quentin", "Rose"]
  
  has_and_belongs_to_many :matches

  def current_match
    unfinished_matches = matches.select { |match| match.over? == false }
    unfinished_matches.sort_by { |match| match.updated_at }.last
  end
end

class NullUser
  attr_accessor :matches, :name, :client

  def initialize
    @name = "none"
    @matches = []
  end

  def save
  end

  def current_match
  end

  def eql?(nulluser)
    nulluser.is_a? NullUser
  end

  alias == eql?

  def hash
    "hash".hash
  end
end
