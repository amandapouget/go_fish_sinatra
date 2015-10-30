require 'integration/integration_spec_helper'

describe 'player view page' do
  let(:players_image_filenames) { Dir.glob('./public/images/players/*.png') }
  let(:cards_image_filenames) { Dir.glob('./public/images/cards/*.png') }
  let(:cardback_image_filename) { './public/images/cards/backs_blue.png' }
  let(:face_up_card_filenames) { cards_image_filenames.clone.tap { |cards| cards.delete(cardback_image_filename) } }
  let(:image_parent_folder) { './public' }
  let(:fish_filename) { '/images/fish_blue.png' }

  NUM_PLAYERS.times do |player_id|
    feature "displays game correctly for player[#{player_id}] after deal" do
      before :each do
        visit ('/player/' + player_id.to_s)
        @other_player_ids = (0..(NUM_PLAYERS - 1)).to_a.tap { |player_ids| player_ids.delete(player_id) }
      end

      it_behaves_like "a Go Fish page with layout"

      it 'has all of the player images' do
       players_image_filenames.each do |file|
          file_name = file.sub(/^.\/public/,'')
          expect(page).to have_xpath("//img[contains(@src,'#{file_name}')]")
        end
      end

      it 'has the blue announcement fish' do
        expect(page).to have_xpath("//img[contains(@src,'#{fish_filename}')]")
      end

      it 'has the speech bubble for making game announcements' do
        expect(page).to have_selector(:xpath, "//div[@id= 'speech']") # only testing for div, need to test for actual bubble css...
      end

      it 'has only face-up cards in the your cards div' do
        within(:xpath, "//div[@id = 'your cards']") do
          find_all('img').each do |img_element|
            expect(face_up_card_filenames.include?(image_parent_folder + "#{img_element[:src]}")).to be true
          end
        end
      end

      it 'does not have face-up cards next to the other players icons' do
        @other_player_ids.each do |other_player_id|
          within(:xpath, "//div[@id = 'player[#{other_player_id}]']") do
            find_all('img').each do |img_element|
              expect(face_up_card_filenames.include?(image_parent_folder + "#{img_element[:src]}")).to be false
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
