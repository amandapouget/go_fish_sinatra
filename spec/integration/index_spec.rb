require 'capybara/rspec'
require './app'

Capybara.app = Sinatra::Application
set(:show_exceptions, false) # "After line 3 in your integration testing spec (Capybara.app = Sinatra::Application), add the line set(:show_exceptions, false) to ensure that when a test is passing there are no errors." What does this mean?

FISH = "/images/fish_blue.png"
RESTART = 'Restart Game'

describe 'Index' do
  feature 'initial page open' do
    before do
      visit '/'
    end

    it 'see the Go Fish header' do
      expect(page).to have_content("Go Fish")
    end

    it 'makes sure all of the player images are on the page' do
      player_image_filenames = Dir.glob('./public/images/players/*.png')
      player_image_filenames.each do |file|
        file_name = file.sub(/^.\/public/,'')
        expect(page).to have_xpath("//img[contains(@src,'#{file_name}')]")
      end
    end

    it 'has the blue announcement fish' do
      expect(page).to have_xpath("//img[contains(@src,'#{FISH}')]")
    end

    it 'has the speech bubble for making game announcements' do
      expect(page).to have_css("#speech") # only tests presence of div, not what the css supplies it
    end

    it 'has a button to reload the page' do
      click_on(RESTART)
      expect(current_path).to eq '/'
    end
  end
end

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
