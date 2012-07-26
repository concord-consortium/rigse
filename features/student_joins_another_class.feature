Feature: Student joins another class

  In order to be part of a class
  As a student
  I want to join the class after I have already registered

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name          | teacher |
      | Default Class | teacher |

  @javascript
  Scenario: Student joins another class
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the class "My Class" has the class word "word"
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the student "student" belongs to class "Default Class"
    And I am logged in with the username student
    And I am on the home page
    And I fill in "clazz_class_word" with "word"
    And I press "Submit"
    Then I should see "joe user"
    When I press "Join"
    Then I should see "Successfully registered for class."
    And the student "student" should belong to the class "My Class"

  @javascript
  Scenario: Student joins another class with invalid information
    Given the option to allow default classes is enabled
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the class "My Class" has the class word "word"
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the student "student" belongs to class "Default Class"
    And I am logged in with the username student
    And I am on the home page
    And I press "Submit"
    Then I should see "Please enter a valid class word and try again."
    When I fill in "clazz_class_word" with "word"
    And I press "Submit"
    Then I should see "joe user"
    And I should not see "Please enter a valid class word and try again."
    When I press "Join"
    Then I should see "Successfully registered for class."
    And the student "student" should belong to the class "My Class"

  @javascript
  Scenario: With the default class enabled, student joins another class
    Given the option to allow default classes is enabled
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the class "My Class" has the class word "word"
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the student "student" belongs to class "Default Class"
    And I am logged in with the username student
    And I am on the home page
    And I fill in "clazz_class_word" with "word"
    And I press "Submit"
    Then I should see "By joining this class, the teacher joe user will be able to see all of your current and future work. If do not want to share your work, but do want to join the class please create a second account and use it to join the class"
    And I should see "Click 'Join' to continue registering for this class."
    When I press "Join"
    Then I should see "Successfully registered for class."
    And the student "student" should belong to the class "My Class"

  @javascript
  Scenario: With the default class enabled, student joins another class with invalid information
    Given the option to allow default classes is enabled
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the class "My Class" has the class word "word"
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the student "student" belongs to class "Default Class"
    And I am logged in with the username student
    And I am on the home page
    And I press "Submit"
    Then I should see "Please enter a valid class word and try again."
    When I fill in "clazz_class_word" with "word"
    And I press "Submit"
    Then I should see "By joining this class, the teacher joe user will be able to see all of your current and future work. If do not want to share your work, but do want to join the class please create a second account and use it to join the class"
    And I should see "Click 'Join' to continue registering for this class."
    And I should not see "Please enter a valid class word and try again."
    When I press "Join"
    Then I should see "Successfully registered for class."
    And the student "student" should belong to the class "My Class"
