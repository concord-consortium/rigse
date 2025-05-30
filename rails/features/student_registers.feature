Feature: Student registers to use the portal

  As a potential student
  I want to register
  In order to access my classes

  Background:
    Given The default settings exist using factories
    And the database has been seeded

  @javascript
  Scenario: Anonymous user signs up as student
    Given I am an anonymous user
    And the option to allow default classes is disabled
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
    And I should see "Your username is: estudent"
    And I should not see "Sorry, there was an error creating your account"
    When I login with username: estudent password: password
    Then I should see "Signed in successfully."


  Scenario: Anonymous user signs up as student with form errors
    And the following classes exist:
      | name       | teacher |
      | Test Class | teacher |
    And the class "Test Class" has the class word "word"
    When I go to the pick signup page
    And I press "Sign up as a student"
    Then I should see "Student Signup"
    When I press "Submit"
    Then I should see "8 errors prohibited this user from being saved"
    When I fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Student             |
      | user_password              | password            |
      | user_password_confirmation | password            |
      | clazz_class_word           | word                |

    And I press "Submit"
    Then I should see "Success!"

  @javascript
  Scenario: Class words are not case sensitive
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
      | clazz_class_word           | Word                |

    And I press "Submit"
    Then I should see "Success!"
    And I should not see "Sorry, there was an error creating your account"
    When I login with username: estudent password: password
    Then I should see "Signed in successfully."

  @javascript
  @wip #RAILS-UPGRADE-TODO
  Scenario: Student registered when default classes are enabled
    Given the option to allow default classes is enabled
    When I go to the pick signup page
    And I press "Sign up as a student"
    Then I should see "Student Signup"
    And I should not see "Class Word"
    When I fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Student             |
      | user_password              | password            |
      | user_password_confirmation | password            |
    And I press "Submit"
    Then I should see "Your username is: estudent"
    And I should not see "Sorry, there was an error creating your account"
    When I login with username: estudent password: password
    And I should see "Signed in successfully."

  @javascript
  Scenario: Student under 18 registered when student consent is enabled
    Given the default settings has student consent enabled
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
      | clazz_class_word           | Word                |
    And I choose "user_of_consenting_age_false"
    And I press "Submit"
    Then I should see "Success!"
    And I should not see "Sorry, there was an error creating your account"
    When I login with username: estudent password: password
    Then I should see "Signed in successfully."

  @javascript
  Scenario: Student over 18 registers and gives consent
    Given the default settings has student consent enabled
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
      | clazz_class_word           | Word                |
    And I choose "user_of_consenting_age_true"
    And I choose "user_have_consent_true"
    And I press "Submit"
    Then I should see "Success!"
    And I should not see "Sorry, there was an error creating your account"
    When I login with username: estudent password: password
    Then I should see "Signed in successfully."

  @javascript
  Scenario: Student over 18 registered and doesn't give consent
    Given the default settings has student consent enabled
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
      | clazz_class_word           | Word                |
    And I choose "user_of_consenting_age_true"
    And I choose "user_have_consent_false"
    And I press "Submit"
    Then I should see "Success!"
    And I should not see "Sorry, there was an error creating your account"
    When I login with username: estudent password: password
    Then I should see "Signed in successfully."
