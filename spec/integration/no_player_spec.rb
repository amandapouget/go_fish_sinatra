require 'integration/integration_spec_helper'

feature 'player not found page' do
  before do
    visit '/player/6'
  end

  it_behaves_like "a Go Fish page with layout"

  it 'includes the no player message' do
    expect(page).to have_selector('div#no_player_message')
  end
end
