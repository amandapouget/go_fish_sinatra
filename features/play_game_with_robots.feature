Feature: Play game with robots
  In order to play Go fish
  As a player
  I want to be able to play against an auto-playing robot

  Background:
    Given the game has started with robots

  @javascript # reused
  Scenario: It's another player's turn so I can't play
    Given it is already the turn of my first opponent
    When I ask my first opponent for cards he has
    Then the request is ignored

  @javascript
  Scenario: After I play, turn passes to the robot and then back to me
    Given it is already my turn
    When I ask my first opponent for cards he does not have
    Then turn advances correctly and informs me of play
