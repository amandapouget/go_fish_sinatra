Feature: See Game
  In order to play Go Fish
  As a player
  I want to see the right things so I can play the game

  Background:
    Given the game has started

  Scenario: what I can see
    When I look at the game
    Then I can see: my cards, my score, the height of the stack of cards in the deck, my opponents, and what's happening in the game.

  Scenario: what I can't see
    When I look at the game
    Then I cannot see: the cards of my opponents
