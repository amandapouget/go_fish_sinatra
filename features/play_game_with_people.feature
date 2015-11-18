Feature: Play game with people
  In order to play Go fish
  As a player
  I want it to let me participate in every turn in the right way and prevent players from playing out of turn

  Background:
    Given the game has started with players

  @javascript
  Scenario: It's another player's turn so I can't play
    Given it is already the turn of my first opponent
    When I ask my first opponent for cards he has
    Then the request is ignored

  @javascript
  Scenario: It's my turn and I successfully ask for cards
    Given it is already my turn
    When I ask my first opponent for cards he has
    Then it gives me the cards
    And it tells me what I asked for
    And it tells me cards were won
    And turn does not advance

  @javascript
  Scenario: It's someone else's turn and they successfully ask me for cards
    Given it is already the turn of my first opponent
    When my first opponent asks me for cards I have
    Then it takes the cards from me
    And it tells me what my first opponent asked for
    And it tells me cards were won
    And turn does not advance

  @javascript
  Scenario: It's someone else's turn and they successfully ask another player for cards
    Given it is already the turn of my first opponent
    When my first opponent asks my second opponent for cards he has
    Then it tells me what my first opponent asked for
    And it tells me cards were won
    And turn does not advance

  @javascript
  Scenario: It's my turn, I unsuccessfully ask for cards, and I go fish
    Given it is already my turn
    When I ask my first opponent for cards he does not have
    Then it makes me go fish
    And it tells me what I asked for
    And it tells me fishing happened

  @javascript
  Scenario: It's someone else's turn, they unsuccessfully ask me for cards, and they go fish
    Given it is already the turn of my first opponent
    When my first opponent asks me for cards I do not have
    Then it tells me what my first opponent asked for
    And it tells me fishing happened

  @javascript
  Scenario: It's someone else's turn, they unsuccessfully ask another player for cards, and they go fish
    Given it is already the turn of my first opponent
    When my first opponent asks my second opponent for cards he does not have
    Then it tells me what my first opponent asked for
    And it tells me fishing happened

  @javascript
  Scenario: I fish the right rank
    Given it is already my turn
    When I go fish and draw the rank I asked for
    Then it tells me the right rank was drawn
    And turn does not advance

  @javascript
  Scenario: Someone else fishes the right rank
    Given it is already the turn of my first opponent
    When my first opponent goes fish and draws the rank he asked for
    Then it tells me the right rank was drawn
    And turn does not advance

  @javascript
  Scenario: I fish a different rank
    Given it is already my turn
    When I go fish and draw a different rank
    Then turn advances

  @javascript
  Scenario: Someone else fishes a different rank
    Given it is already the turn of my first opponent
    When my first opponent goes fish and draws a different rank
    Then turn advances
