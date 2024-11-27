Feature: Password Reset Form
  As a user,
  I want the ability to submit a new password in a secure form after clicking a password reset link,
  So that I can successfully change my password and regain access to my account.

  Background:
    Given the following users exist:
      | name         | email              | password    |
      | ExampleUser | user@example.com   | oldpassword |
      | AnotherUser | another@example.com | test12345   |

  Scenario: User resets password using a valid reset link
    Given the following users have requested password reset:
      | name         | email              |
      | ExampleUser | user@example.com   |
    Given a valid password reset link exists for "user@example.com"
    When I visit the reset link with valid token
    Then I should be on the password reset page
    And I fill in the password field with "newpassword"
    And I fill in the password confirmation field with "newpassword"
    And I click the "Submit" button
    Then I should see "Password has been reset."
    Then I should be on "/login"

  Scenario: Invalid user tries to reset password
    When I visit the reset link with token "invalidtoken"
    Then I should be on "/login"
    Then I should see "Invalid User"

  Scenario: User leaves the password field blank
    Given the following users have requested password reset:
      | name         | email              |
      | ExampleUser | user@example.com   |
    Given a valid password reset link exists for "user@example.com"
    When I visit the reset link with valid token
    Then I should be on the password reset page
    And I fill in the password field with ""
    And I fill in the password confirmation field with ""
    And I click the "Submit" button
    Then I should see "Password can't be empty"


  Scenario: Reset password and log in with new password
    Given the following users exist:
      | name         | email              | password    |
      | ExampleUser | hans@uiowa.edu   | oldpassword |
    Given the following users have requested password reset:
      | name         | email              |
      | ExampleUser | hans@uiowa.edu   |
    Given a valid password reset link exists for "hans@uiowa.edu"
    When I visit the reset link with valid token
    And I fill in the password field with "newpassword"
    And I fill in the password confirmation field with "newpassword"
    And I click the "Submit" button
    Then I should be on "/login"
    When I fill in "email_field" with "hans@uiowa.edu"
    And I fill in "password_field" with "newpassword"
    And I click the "Sign in" button
    Then I should be on "/landing"

