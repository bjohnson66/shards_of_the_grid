# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 4th 2024 to December 15, 2024.
# The AI Generated code was not sufficient or functional outright nor was it copied at face value.
# Using our knowledge of software engineering, ruby, rails, web development, and the constraints of
# our customer, SELT Team 007 (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson, and Sheng Wang)
# used GAITs responsibly; verifying that each line made sense in the context of the app,
# conformed to the overall design, and was testable.
# We maintained a strict peer review process before any code changes were merged into the development
# or production branches. All code was tested with BDD and TDD tests as well as empirically tested
# with local run servers and Heroku deployments to ensure compatibility.
# *********************************************************************
Feature: Join a Game
    As a player
    I want to join an existing game lobby
    So that I can play the game with other players

  Background:
    Given the following users exist and want to create a game:
      | name        | email            | password    |
      | ExampleUser | user@example.com | oldpassword |
      | TestUser    | test@example.com | testpass    |
    And I am logged in as "user@example.com" with password "oldpassword"

  Scenario: Successfully joining an existing game lobby
    Given a game exists for joining with join code "A1B2C3"
    When I navigate to the landing page
    And I click on the "Join Game" button
    And I fill in "join_game_join_code" with "A1B2C3"
    And I submit the join game form
    Then I should see "You have successfully joined the game."
    When I navigate back to the landing page
    And the game "Mystic Quest" should be listed in my games

  Scenario: Attempting to join a game with an invalid join code
    Given a game exists for joining with join code "A1B2C3"
    When I navigate to the landing page
    And I click on the "Join Existing Game" button
    And I fill in "join_game_join_code" with "INVALID"
    And I submit the join game form
    Then I should see "Invalid join code."