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
  end

  [MAX_PLAYERS].each do |num_players|
    feature "funnels to correct game for games with #{num_players}" do
      after do
        reset_pending
        Match.clear
      end

      def fill_form(player_name, num_players)
        visit '/'
        fill_in 'name', :with => player_name
        choose(num_players)
        click_button 'Start Game'
      end

      it 'upon submit, goes to waiting for players page' do
        fill_form("Anna", num_players)
        expect(current_path).to match /start_game/
      end

      it 'creates a match when there are enough players to start a game, and, it allows for simultaneous matches' do
        2.times do |time|
          (num_players).times { PENDING_USERS[num_players] << User.new }
          make_game(test: true)
          expect(PENDING_USERS[num_players]).to be_empty
          expect(Match.all.length).to eq time + 1
        end
      end

      it 'redirects to the game when the last player joins', :js => true do
        (num_players - 1).times { PENDING_USERS[num_players] << User.new }
        fill_form('Echo', num_players)
        make_game(test: true)
        sleep 1.5
        expect(current_path).to match /.*\/player\/.*/
      end
    end
  end
end
