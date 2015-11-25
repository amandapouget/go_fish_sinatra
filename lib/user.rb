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
  attr_accessor :matches, :current_match

  validates :name, presence: true

  after_save :cache_client

  def matches
    @matches ||= []
  end

  def add_match(match)
    @current_match = match.object_id
    (matches << @current_match).uniq!
  end

  def write_attribute(attribute, value)
    self.client = value if (attribute == 'client')
    super
  end

  def client=(client)
    @client = client
    cache_client
  end

  def client
    if new_record?
      @client
    else
      clients[id]
    end
  end

  def cache_client
    clients[id] = @client unless new_record?
  end

  private

  def clients
    @@clients ||= {}
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
