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

class User < ActiveRecord::Base
  attr_accessor :matches, :client
  #
  # def initialize(name: nil, client: nil)
  #   @client = client
  #   @name = name || FAKENAMES.rotate![0]
  #   @matches = []
  # end

  def add_match(match)
    (@matches << match.object_id).uniq!
  end
end

class NullUser
  attr_accessor :matches, :name, :client

  def initialize
    @matches = []
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
