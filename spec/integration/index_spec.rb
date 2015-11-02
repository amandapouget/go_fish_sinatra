require 'integration/integration_spec_helper'

describe 'homepage' do
  feature 'has certain content' do
    before do
      visit '/'
    end

    it_behaves_like "a Go Fish page with layout"

    it 'includes a start button' do
      expect(page).to have_content 'Start Game'
    end

    it 'asks the player for the number of players' do
      expect(page).to have_content /Players in your game/i
    end

    it 'asks the player for their name' do
      expect(page).to have_content /name/i
    end

    PLAYER_RANGE.each do |num_players|
      it 'upon submit, goes to the player page for the first player' do
        fill_in 'name', :with => 'Anna'
        find("##{num_players}").click
        click_button 'Start Game'
        expect(current_path).to match /\/.*\/player\/0/
      end
    end
  end
end
