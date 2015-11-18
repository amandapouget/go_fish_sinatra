Feature: Start Game
  In order to play Go Fish
  As a player
  I want it to start the game when there are enough players

  Background:
    Given I am waiting for my game to start
    And the game is short one player

  @javascript
  Scenario: Wait for the right player
    When the wrong kind of player joins
    Then it continues to wait for the right player

  @javascript
  Scenario: The right player joins
    When the right kind of player joins
    Then it starts our game

  @javascript
  Scenario: No one joins; I play a robot
    When I ask to play robots because no one has joined
    Then it starts our game
