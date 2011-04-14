Feature: Teacher registers to use the portal

ITSI-SU requires that teachers self-register.

  As a potential teacher
  I want to create a teacher account
  So that I can use the investigations portal as a teacher

  Background:
    Given The default project and jnlp resources exist using factories

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
    And I should not see "Sorry, there was an error creating your account"

  Scenario: Anonymous user signs up as teacher with form errors
    Given I am an anonymous user
    When I go to the pick signup page
    And I press "Sign up as a teacher"
    Then I should see "Teacher Signup Page"
    When I press "Submit"
    Then I should see "10 errors prohibited this user from being saved"
    And "4" fields should have the class selector ".fieldWithErrors"
    When I fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Teacher             |
      | user_email                 | example@example.com |
      | user_login                 | login               |
      | user_password              | password            |
      | user_password_confirmation | password            |

    And I select a school from the list of schools
    And I press "Submit"
    Then I should see " Thanks for signing up!"
