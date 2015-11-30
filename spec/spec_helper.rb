ENV['RACK_ENV'] = 'test'
require 'sinatra/activerecord'
# require 'rails-observers'
require 'rspec'
require 'pry'
require 'socket'
require 'factory_girl'

def require_all(dir)
  Dir[File.expand_path(File.join(File.dirname(File.absolute_path(__FILE__)), dir)) + "/**/*.rb"].each { |file| require file }
end
require_all '../lib/'
require_all '../spec/factories'

Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.after(:all) do
    Match.destroy_all
    User.destroy_all
  end
  # ActiveRecord::Base.add_observer MatchClientNotifier.instance
end
