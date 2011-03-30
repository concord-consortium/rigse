Feature: Student joins default class

  In order to do work without being a member of a specific class
  As a student
  I want to join a "default" class with no class word

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name          | teacher |
      | Default Class | teacher |

  @selenium
  Scenario: Register as a student with no class word
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
    Then I should see "You have successfully registered Example Student with the username estudent."
    And I should not see "Sorry, there was an error creating your account"
    When I login with username: estudent password: password
    And I should see "Logged in successfully"

  @selenium
  Scenario: Student in default class joins another class
    Given the option to allow default classes is enabled
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the class "My Class" has the class word "word"
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the student "student" belongs to class "Default Class"
    When I login with username: student password: student
    And I am on the home page
    And I fill in "clazz_class_word" with "word"
    And I press "Submit"
    Then I should see "By joining this class, the teacher joe user will be able to see all of your current and future work. If do not want to share your work, but do want to join the class please create a second account and use it to join the class"
    And I should see "Click 'Join' to continue registering for this class."
    When I press "Join"
    Then I should see "Successfully registered for class."
    And the student "student" should belong to the class "My Class"
