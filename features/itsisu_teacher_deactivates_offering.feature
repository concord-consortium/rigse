Feature: ITSISU Teacher deactivates an offering
  So that I wont loose learner data
  As an ITSI teacher
  I want to unassign an activity from a class using the bin interface
  Simply by uncheckign the check box in my class edit page.

  Background:
    Given The default project and jnlp resources exist using factories
    Given The theme is "itsisu"
    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the following activities exist:
      | name                | user      | publication_status |
      | Test Activity       | teacher   | published          |
    And the activity "Test Activity" is assigned to the class "My Class"
    And a student has performed work on the activity "Test Activity" for the class "My Class"
    And I login with username: teacher password: teacher

  @selenium
  Scenario: Teacher unchecks the active activity in the bin view
    When I am on the class edit page for "My Class"
    And I click the bin named "My Activities"
    And I uncheck the activity "Test Activity" in the bin view
    Then the activity "Test Activity" should be archived for the class "My Class"

  @selenium
  Scenario: Teacher re-assigns the activity to hir class in the bin view
    When I am on the class edit page for "My Class"
    And I click the bin named "My Activities"
    And I check the activity "Test Activity" in the bin view
    Then the activity "Test Activity" should be active for the class "My Class"

