require 'capybara/rspec'
require './app'
Capybara.app = Sinatra::Application
set(:show_exceptions, false) # "After line 3 in your integration testing spec (Capybara.app = Sinatra::Application), add the line set(:show_exceptions, false) to ensure that when a test is passing there are no errors." What does this mean?

shared_examples_for "a Go Fish page with layout" do
  describe "the layout" do
    let(:restart) { 'Home' }
    let(:game_title) { 'Go Fish' }

    it 'has the game title header' do
      expect(page).to have_content(game_title)
    end

    it 'has a button to go to the homepage' do
      click_on(restart)
      expect(current_path).to eq '/'
    end
  end
end
