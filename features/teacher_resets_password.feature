Feature: Teacher resets password

  In order to log in after I forgot my old password
  As a teacher
  I want to reset my password

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded

  @javascript
  Scenario: Anonymous user signs up as teacher
    Given I am an anonymous user
    When I go to the pick signup page
    And I press "Sign up as a teacher"
    Then I should see "Teacher Signup Page"
    When I fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Teacher             |
      | user_email                 | example@example.com |
      | user_login                 | login               |
      | user_password              | password            |
      | user_password_confirmation | password            |

    And I select a school from the list of schools
    And I press "Submit"
    Then I should see "Thanks for signing up!"
    And "example@example.com" should receive an email
    When I open the email
    Then I should see "Please activate your new account" in the email subject
    When I follow "/confirmation" in the email
    Then I should see "Your account was successfully confirmed. You are now signed in."

