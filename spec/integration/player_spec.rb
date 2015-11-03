require 'integration/integration_spec_helper'

feature 'player view page' do
  let(:players_image_filenames) { Dir.glob('./public/images/players/*.png') }
  let(:cards_image_filenames) { Dir.glob('./public/images/cards/*.png') }
  let(:cardback_image_filename) { './public/images/cards/backs_blue.png' }
  let(:face_up_card_filenames) { cards_image_filenames.clone.tap { |cards| cards.delete(cardback_image_filename) } }
  let(:image_parent_folder) { './public' }
  let(:fish_filename) { '/images/fish_blue.png' }

  PLAYER_RANGE.each do |num_players|
    num_players.times do |player_id|
      feature "game with #{num_players} players displays correctly for player #{player_id}" do
        before do
          visit "/#{num_players}/player/#{player_id}"
        end

        it_behaves_like "a Go Fish page with layout"

        it 'has all the player names and all the required player images' do
          # not sure how to test the names part
          player_image_count = 0
          players_image_filenames.each do |file|
            file_name = file.sub(/^.\/public/,'')
            player_image_count +=1 if page.has_selector? "img[@src = '#{file_name}']"
          end
          expect(player_image_count).to eq num_players
        end

        it 'has the blue announcement fish and the speech bubble for making game announcements' do
          expect(page).to have_selector "img[@src = '#{fish_filename}']"
          expect(page).to have_selector "#speech" # only testing for div, need to test for actual bubble css...
        end

        it 'had only face_up cards in the your_cards div, and no face_cards next to opponent icons' do
          find_all('.your_cards').each { |card| expect(face_up_card_filenames).to include (image_parent_folder + "#{card[:src]}") }
          (num_players - 1).times do |opponent_index|
            within "#opponent_#{opponent_index}" do
              find_all('img').each { |img_element| expect(face_up_card_filenames).to_not include (image_parent_folder + "#{img_element[:src]}") }
            end
          end
        end
      end
    end
  end
end

# page.should have_selector('h2', text: /#{headline}/i)

# within login_form do
#   fill_in "Email", :with => "jonas@elabs.se"
#   fill_in "Password", :with => "capybara"
#   click_button "Login"
# end

# expect(page).to have_xpath("//img[contains(@src,'player_bee.png')]")
# expect(page).to have_xpath("//img[contains(@src,'#{File.basename(promotion.image.url)}')]")

# describe('CD Organizer') do
#   before do
#     CD.clear
#     Artist.clear
#   end
#
#   describe('the create new CD by this Artist page', {:type => :feature}) do
#     it('pre-fills Artist name and then takes in title and displays Artist page--with new CD listed--upon submit') do
#       visit('/artist_new_form')
#       fill_in('name', :with => 'Edith Piaf')
#       click_button('Create Artist')
#       visit('/artist/Edith_Piaf')
#       click_link('Create New CD by Edith Piaf')
#       fill_in('title', :with => 'Greatest Hits')
#       click_button('Create CD')
#       expect(page).to have_content('Edith Piaf')
#       expect(page).to have_content('Greatest Hits')
#     end
#     it('adds the CD to the overall CD list') do
#       visit('/artist_new_form')
#       fill_in('name', :with => 'Edith Piaf')
#       click_button('Create Artist')
#       visit('/artist/Edith_Piaf')
#       click_link('Create New CD by Edith Piaf')
#       fill_in('title', :with => 'Greatest Hits 2')
#       click_button('Create CD')
#       expect(CD.all[0].title).to eq('Greatest Hits 2')
#     end
#   end
# end
