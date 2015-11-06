require 'integration/integration_spec_helper'

feature 'player view page' do
  let(:players_image_filenames) { Dir.glob('./public/images/players/*.png') }
  let(:cards_image_filenames) { Dir.glob('./public/images/cards/*.png') }
  let(:cardback_image_filename) { './public/images/cards/backs_blue.png' }
  let(:face_up_card_filenames) { cards_image_filenames.clone.tap { |cards| cards.delete(cardback_image_filename) } }
  let(:image_parent_folder) { './public' }
  let(:first_prompt) { "click card, player & me to request cards!" }
  let(:go_fish_prompt) { "went fish" }
  let(:got_cards_prompt) { "got cards" }

  [MAX_PLAYERS].each do |num_players|
    num_players.times do |player_id|
      describe "game with #{num_players} players displays correctly for player #{player_id}" do

        before do
          visit "/#{num_players}/player/#{player_id}"
        end

        it_behaves_like "a Go Fish page with layout"

        it 'has all the player names and all the required player images, plus the blue fish and the speech bubble' do
          # not sure how to test the names part
          player_image_count = 0
          players_image_filenames.each do |file|
            file_name = file.sub(/^.\/public/,'')
            player_image_count +=1 if page.has_selector? "img[@src = '#{file_name}']"
          end
          expect(player_image_count).to eq num_players
          expect(page).to have_selector "#fish_blue"
          expect(page).to have_selector "#speech"
        end

        it 'has only face_up cards in the your_cards div, no face_cards next to opponent icons, and tells the first player to request cards' do
          find_all('.your_cards').each { |card| expect(face_up_card_filenames).to include (image_parent_folder + "#{card[:src]}") }
          (num_players - 1).times do |opponent_index|
            within "#opponent_#{opponent_index}" do
              find_all('img').each { |img_element| expect(face_up_card_filenames).to_not include (image_parent_folder + "#{img_element[:src]}") }
            end
          end
          expect(page).to have_content(first_prompt)
        end
      end
    end
  end
end
