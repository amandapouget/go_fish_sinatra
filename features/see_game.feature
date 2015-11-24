Feature: See Game
  In order to play Go Fish
  As a player
  I want to see the right things so I can play the game

  Background:
    Given the game has started

  @javascript
  Scenario: what I can see
    When I look at the game
    Then I can see: my cards, the score, the height of the stack of cards in the deck, the players (name, icon), and what's happening in the game.

  @javascript
  Scenario: what I can't see
    When I look at the game
    Then I cannot see: the cards of my opponents

  @javascript
  Scenario: wrong page
    When I visit the wrong page
    Then I get a funny error message
