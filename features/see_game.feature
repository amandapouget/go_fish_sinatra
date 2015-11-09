Feature: See the Table
  In order to play Go Fish
  As a player
  I want to see the right things so I can play the game

  Scenario: what I can see
    Given we have enough players
    And the game has started
    When I look at the game
    Then I can see: my cards, my score, the height of the stack of cards in the deck, my opponents, and what's happening in the game.

  Scenario: what I can't see
    Given we have enough players
    And the game has started
    When I look at the game
    Then I can't see: my opponents' cards or score
