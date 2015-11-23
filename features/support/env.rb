ENV['RACK_ENV'] = 'test'
require './app'
require 'pg'
require 'sinatra/activerecord'
require 'rspec'
require 'factory_girl'
require './features/steps/helpers'
require 'capybara'
require 'spinach/capybara'
require 'selenium-webdriver'
require 'capybara/poltergeist'
Capybara.app = Sinatra::Application
set(:show_exceptions, false)

# disables poltergeist logging
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    extensions: [ 'features/support/logs.js' ],
    js_errors:   true
  )
end
Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 10

Spinach.hooks.on_tag("javascript") { ::Capybara.current_driver = ::Capybara.javascript_driver }
Spinach.config[:failure_exceptions] << RSpec::Expectations::ExpectationNotMetError
Spinach::FeatureSteps.include RSpec::Matchers
Spinach::FeatureSteps.include FactoryGirl::Syntax::Methods
Spinach.hooks.before_run { FactoryGirl.reload }

# disables rack logging
module Rack
  class CommonLogger
    def call(env)
      # do nothing
      @app.call(env)
    end
  end
end
