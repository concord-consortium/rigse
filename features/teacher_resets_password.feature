Feature: Teacher resets password

  In order to log in after I forgot my old password
  As a teacher
  I want to reset my password

  Background:
    Given The default project and jnlp resources exist using factories

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
    When I click the first link in the email
    Then I should see "Signup complete!"
    When I fill in the following:
      | login    | login    |
      | password | password |
    And I press "Login"
    Then I should see "Logged in successfully"
    Given I am an anonymous user
    And I follow "Forgot Password"
    When I fill in "login" with "login"
    And I press "Submit"
    Then I should see "A link to change your password has been sent to example@example.com."
    And "example@example.com" should receive an email
    And I open the email with subject "You have requested to change your password"
    When I click the first link in the email
    Then I should see "Please enter a new password and confirm it."
    And I fill in "password" with "password2"
    And I fill in "confirm password" with "password2"
    And I press "Submit"
    Then I should see "Password for login was successfully updated."
    When I fill in the following:
      | login    | login    |
      | password | password2 |
    And I press "Login"
    Then I should see "Logged in successfully"
    
