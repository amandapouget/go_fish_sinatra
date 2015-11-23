# class Task < ActiveRecord::Base
#   belongs_to :list
#   validates :description, {presence: true, length: { maximum: 50 }}
#   before_save(:downcase_description)
#
#   scope(:not_done, -> { where({:done => false}) })
#
# private
#
#   def downcase_description
#     self.description.downcase!
#   end
# end

FAKENAMES = ["Marie", "Amanda", "Bob", "Charlie", "David", "Echo", "Frank", "Gertrude", "Helga", "Iggy", "Jaqueline", "Kevin", "Lillian"]

class User
  @@all = []
  attr_accessor :matches, :current_match, :name, :client

  def initialize(name: nil, client: nil)
    @client = client
    @name = name || FAKENAMES.rotate![0]
    @matches = []
    @current_match = nil
    save
  end

  def self.all
    @@all
  end

  def self.find(id)
    User.all.find { |user| user.object_id == id }
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
