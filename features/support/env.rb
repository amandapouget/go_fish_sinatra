require './app'
require 'rspec'
require 'capybara'
require 'factory_girl'
require 'spinach/capybara'
require './features/steps/helpers'
require 'selenium-webdriver'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.app = Sinatra::Application
set(:show_exceptions, false)

Spinach.hooks.on_tag("javascript") { ::Capybara.current_driver = ::Capybara.javascript_driver }
Spinach.config[:failure_exceptions] << RSpec::Expectations::ExpectationNotMetError
Spinach::FeatureSteps.include RSpec::Matchers
Spinach::FeatureSteps.include FactoryGirl::Syntax::Methods
Spinach.hooks.before_run { FactoryGirl.reload }
