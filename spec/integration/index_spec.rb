require 'integration/integration_spec_helper'

def fill_form(player_name, num_players)
  visit '/'
  fill_in 'name', :with => player_name
  choose(num_players)
  click_button 'Start Game'
end

def reset_pending
  (PLAYER_RANGE).each { |num_players| PENDING_USERS[num_players] = [] }
end

describe 'homepage' do
  feature 'has go_fish layout' do
    before do
      visit '/'
    end

    it_behaves_like "a Go Fish page with layout"
  end

  [MAX_PLAYERS].each do |num_players|
    feature "funnels to correct game for games with #{num_players}" do
      after do
        reset_pending
        Match.clear
      end

      it 'upon submit, creates user and goes to waiting for players page' do
        fill_form("Anna", num_players)
        expect(PENDING_USERS[num_players].length).to eq 1
        expect(current_path).to match /wait/
      end

      it 'creates a match when there are enough players to start a game, and, it allows for simultaneous matches' do
        2.times do |time|
          (num_players).times { PENDING_USERS[num_players] << build(:user) }
          last_user_id = PENDING_USERS[num_players].last.object_id
          make_game(last_user_id, num_players)
          expect(PENDING_USERS[num_players]).to be_empty
          expect(Match.all.length).to eq time + 1
        end
      end

      it 'redirects to the game when the last player joins', :js => true do
        (num_players - 1).times { PENDING_USERS[num_players] << build(:user) }
        fill_form('Echo', num_players)
        until current_path != "/wait"
        end
        expect(current_path).to match /.*\/player\/.*/
      end
    end
  end
end
