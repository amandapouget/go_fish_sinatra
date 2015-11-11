require 'rspec'
require 'pry'
require 'socket'
require 'factory_girl'

require 'card'
require 'deck'
require 'player'
require 'game'
require 'user'
require 'match'
require 'mock_client'
require 'server'
require 'client'
require 'rank_request'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.before(:all) { FactoryGirl.reload }
end
