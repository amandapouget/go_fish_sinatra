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

    it 'asks the player for their name and the number of players' do
      expect(page).to have_content /name/i
      expect(page).to have_content /Players in your game/i
    end
  end

  PLAYER_RANGE.each do |num_players|
    feature "funnels to correct game for games with #{num_players}" do
      def fill_form(name, num_players)
        visit '/'
        fill_in 'name', :with => name
        find("##{num_players}").click
        click_button 'Start Game'
      end

      it 'upon submit, goes to wait for players page for the first player' do
        fill_form('Anna', num_players)
        expect(current_path).to match /start_game/
      end

      it 'if a game of that number already exists and is waiting for players, joins that game' do
        names = ['Alpha','Bravo','Charlie','David','Echo']
        match_ids = []
        names[0...num_players].each_with_index do |player, index|
          fill_form(player, num_players)
          match_ids << current_path.sub("/player/#{index}","")
          expect(match_ids.uniq.length).to eq 1
        end
      end
    end
  end
end
