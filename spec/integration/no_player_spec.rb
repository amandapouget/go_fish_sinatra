require 'integration/integration_spec_helper'

feature 'player not found page' do
  PLAYER_RANGE.each do |num_players|
    describe "game with #{num_players} players" do
      before do
        visit "/#{num_players}/player/#{num_players + 1}"
      end

      it_behaves_like "a Go Fish page with layout"

      it 'includes the no player message' do
        expect(page).to have_selector('div#no_player_message')
      end
    end
  end
end
