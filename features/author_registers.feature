Feature: An author registers to use the portal

  As a potential student
  I want to register
  In order to author content on the portal

  Background:
    Given The default project and jnlp resources exist using factories

	@selenium
  Scenario: Anaonymous user signs up as an author
    Given I am an anonymous user
    When I go to the pick signup page
    And I press "Sign up as a member"
    Then I should see "Signup"
    When I fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Author              |
      | user_email                 | example@example.com |
      | user_login                 | login               |
      | user_password              | password            |
      | user_password_confirmation | password            |

    And I press "Sign up"
    Then I should see " Thanks for signing up!"
    And "example@example.com" should receive an email
    When I open the email
    Then I should see "Please activate your new account" in the email subject
    When I click the first link in the email
    Then I should see "Signup complete!"
    When I fill in the following:
      | login    | login    |
      | password | password |
    And I press "Submit"
    Then I should see "Logged in successfully"
    And I should not see "Sorry, there was an error creating your account"

  Scenario: Anonymous user signs up as an author with form errors
    Given I am an anonymous user
    When I go to the pick signup page
    And I press "Sign up as a member"
    Then I should see "Signup"
    When I press "Sign up"
    Then I should see "9 errors prohibited this user from being saved"
    And "8" fields should have the class selector ".fieldWithErrors"
    When I fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Author              |
      | user_email                 | example@example.com |
      | user_login                 | login               |
      | user_password              | password            |
      | user_password_confirmation | password            |

    And I press "Sign up"
    Then I should see " Thanks for signing up!"
