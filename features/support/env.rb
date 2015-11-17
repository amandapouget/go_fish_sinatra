require './app'
require 'rspec'
require 'capybara'
require 'factory_girl'
require 'spinach/capybara'
require './features/steps/helpers'
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
