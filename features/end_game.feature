Feature: End Game
  In order to play Go Fish
  As a player
  I want it to end the game at the right time and give me game stats

  Scenario: I am out of cards
    Given the game is on-going
    When I run out of cards
    Then it tells me the game is over
    And it displays everyone's final score

  Scenario: An opponent is out of cards
    Given the game is on-going
    When an opponent runs out of cards
    Then it tells me the game is over
    And it displays everyone's final score

  Scenario: The deck is out of cards
    Given the game is on-going
    When the deck runs out of cards
    Then it tells me the game is over
    And it displays everyone's final score
