Feature: Student registers to use the portal

  As a potential student
  I want to register
  In order to access my classes

  Background:
    Given The default project and jnlp resources exist using factories

  @selenium
  Scenario: Anonymous user signs up as student
    Given I am an anonymous user
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name       | teacher |
      | Test Class | teacher |
    And the class "Test Class" has the class word "word"
    When I go to the pick signup page
    And I press "Sign up as a student"
    Then I should see "Student Signup"
    When I fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Student             |
      | user_password              | password            |
      | user_password_confirmation | password            |
      | clazz_class_word           | word                |

    And I press "Submit"
    Then I should see "Success!"
    And I should not see "Sorry, there was an error creating your account"
    When I login with username: estudent password: password
    Then I should see "Logged in successfully"

  Scenario: Anonymous user signs up as student with form errors
    Given I am an anonymous user
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name       | teacher |
      | Test Class | teacher |
    And the class "Test Class" has the class word "word"
    When I go to the pick signup page
    And I press "Sign up as a student"
    Then I should see "Student Signup"
    When I press "Submit"
    Then I should see "6 errors prohibited this user from being saved"
    And "2" fields should have the class selector ".fieldWithErrors"
    When I fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Student             |
      | user_password              | password            |
      | user_password_confirmation | password            |
      | clazz_class_word           | word                |

    And I press "Submit"
    Then I should see "Success!"

