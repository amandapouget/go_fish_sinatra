ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'pry'
require 'socket'
require 'factory_girl'

def require_all(dir)
  Dir[File.expand_path(File.join(File.dirname(File.absolute_path(__FILE__)), dir)) + "/**/*.rb"].each { |file| require file }
end

require_all '../lib/'
require_all '../spec/factories'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.after(:each) do
    # Match.all().each() { |match| match.destroy }
    # User.all().each { |user| user.detroy }
  end
end


RSpec.configure do |config|

end
