require 'rspec'
require 'pry'
require 'socket'
require 'factory_girl'

def require_all(_dir)
  Dir[File.expand_path(File.join(File.dirname(File.absolute_path(__FILE__)), _dir)) + "/**/*.rb"].each { |file| require file }
end

require_all '../lib/'
require_all '../spec/factories'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
