Feature: End Game
  In order to play Go Fish
  As a player
  I want it to end the game at the right time and give me game stats

  Background:
    Given the game has started

  @javascript
  Scenario: I am out of cards
    When I run out of cards
    Then it tells me the game is over and displays everyone's final score

  @javascript
  Scenario: An opponent is out of cards
    When an opponent runs out of cards
    Then it tells me the game is over and displays everyone's final score

  @javascript
  Scenario: The deck is out of cards
    When the deck runs out of cards
    Then it tells me the game is over and displays everyone's final score
