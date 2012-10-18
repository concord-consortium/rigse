Feature: Student runs html activity
  In order to use an html activity
  As a student
  I want to "run" the activity

  Background:
    Given the most basic default project
    Given use jnlps are disabled
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And a simple activity with a multiple choice exists
    And the student "student" belongs to class "My Class"
    And the activity "simple activity" is assigned to the class "My Class"
    And I login with username: student

  Scenario: Student runs html
    When I follow "run simple activity"
    And I press "Submit"

  @javascript
  Scenario: Student runs html and teacher sees recent activity
    When I follow "run simple activity"
    And I choose "Choice 1"
    And I press "Submit"
    And I login with username: teacher
    And I follow "Recent Activity"
    # And I debug

  # Ideally we should try using hooks and tags, but I couldn't
  # get that to owrk around the background
  Scenario: I clean things up after these tests run...
    Then use jnlps is reset to the original setting

