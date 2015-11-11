require './app'
require 'rspec'
require 'capybara'
require 'spinach/capybara'
require './features/steps/helpers'
require 'selenium-webdriver'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.app = Sinatra::Application
set(:show_exceptions, false)

Spinach.hooks.on_tag("javascript") do
  ::Capybara.current_driver = ::Capybara.javascript_driver
end
Spinach.config[:failure_exceptions] << RSpec::Expectations::ExpectationNotMetError
Spinach::FeatureSteps.include RSpec::Matchers
