Feature: Create or Join Game
  In order to play Go Fish
  As a player
  I want it to let me start or join a game so I can play with the number of players I want

  Scenario: Create a new game
    Given no pending game exists with the number of players I want
    When I tell it my name and how many players I want
    Then it creates the kind of pending game I want and waits for players to join

  Scenario: Join an existing game
    Given a pending game exists for the number of players I want
    When I tell it my name and how many players I want
    Then it joins me to the kind of pending game I want and waits for players to join
