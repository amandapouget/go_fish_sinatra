Feature: Play game
  In order to play Go Fish
  As a player
  I want it to let me participate in every turn in the right way and prevent players from playing out of turn

  @javascript
  Scenario: It's another player's turn so I can't play
    Given the game is on-going
    And it is already another player's turn
    When I ask an opponent for cards of a given rank
    Then the request is ignored

  Scenario: It's my turn and I successfully ask for cards
    Given the game is on-going
    And it is already my turn
    When I ask an opponent for cards of a given rank
    And they have cards of that rank
    Then it tells me what I asked for
    And it tells me I got cards
    And it gives me the cards
    And it is still my turn

  Scenario: It's someone else's turn and they successfully ask me for cards
    Given the game is on-going
    And it is already another player's turn
    When they ask me for cards of a given rank
    And I have cards of that rank
    Then it tells me what they asked for
    And it gives them the cards
    And it is still their turn

  Scenario: It's someone else's turn and they successfully ask another player for cards
    Given the game is on-going
    And it is already another player's turn
    When they ask someone else for cards of a given rank
    And they have cards of that rank
    Then it tells me what they asked for
    And it tells me they got cards
    And it gives them the cards
    And it is still their turn

  Scenario: It's my turn, I unsuccessfully ask for cards, and I go Fish
    Given the game is on-going
    And it is already my turn
    When I ask an opponent for cards of a given rank
    And they do not have cards of that rank
    Then it makes me go Fish
    And it tells me what I asked for
    And it tells me I went fish

  Scenario: It's someone else's turn, they unsuccessfully ask me for cards, and they go Fish
    Given the game is on-going
    And it is already another player's turn
    When they ask me for cards of a given rank
    And I do not have cards of that rank
    Then it makes them go Fish
    And it tells me what they asked for
    And it tells me they went Fish

  Scenario: It's someone else's turn, they unsuccessfully ask another player for cards, and they go Fish
    Given the game is on-going
    And it is already another player's turn
    When they ask someone else for cards of a given rank
    And they do not have cards of that rank
    Then it makes them go Fish
    And it tells me what they asked for
    And it tells me they went Fish

  Scenario: I fish the right rank
    Given I do not get the cards I asked for
    When I go fish
    And I draw the rank I asked for
    Then it tells me I drew the right rank
    And it is still my turn

  Scenario: Someone else fishes the right rank
    Given Someone else does not get the cards they asked for
    When they go fish
    And they draw the rank they asked for
    Then it tells me they drew the right rank
    And it is still their turn

  Scenario: I fish a different rank
    Given I do not get the cards I asked for
    When I go fish
    And I draw a different rank from the one I asked for
    Then it is someone else's turn

  Scenario: Someone else fishes a different rank
    Given Someone else does not get the cards they asked for
    When they go fish
    And they draw a different rank from the one they asked for
    Then it is someone else's turn
