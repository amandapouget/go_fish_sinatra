class Spinach::Features::SeeGame < Spinach::FeatureSteps
  include FreshGameCreate

  step 'the game has started' do
    reset
    start_three_game
    @match.game.deal
  end

  step 'I look at the game' do
    visit_player_page
  end

  step 'I can see: my cards, my score, the height of the stack of cards in the deck, my opponents, and what\'s happening in the game.' do
    expect_page_has_cards(my_cards)
    expect(page).to have_selector '#books'
    expect(page).to have_content @match.game.deck.count_cards
    @match.players.each do |player|
      expect(page).to have_selector "img[@src = '#{player.icon}']"
      expect(page).to have_content player.name
    end
    expect(page).to have_selector "#fish_blue"
    expect(page).to have_selector "#speech"
    expect(page).to have_content @match.message
  end

  step 'I cannot see: the cards of my opponents' do
    face_up_card_filename = /^[cdhs].*.png/
    (@num_players - 1).times do |opponent_index|
      within "#opponent_#{opponent_index}" do
        find_all('img').each { |img_element| expect("#{img_element[:src]}").not_to match face_up_card_filename }
      end
    end
  end
end
