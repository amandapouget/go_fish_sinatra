class RealUser < User
  validates :name, presence: true
  after_save :cache_client

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
