Feature: Student views report

  In order to know how I did on material
  As an student
  I need to access the student report

  Background:
    Given the most basic default settings
    And the database has been seeded
    And a simple activity with a multiple choice exists
    And the activity "simple activity" is assigned to the class "Class_with_no_assignment"
  
  @lightweight
  Scenario: Student sees report link
    When I login with username: davy
    Then I should not see "Generate a report of my work"
    And I should not see "Last run"
    When run the activity
    And choose "Choice 1"
    And I press "Submit"
    Then I should see "Last run"
    When I should see "Generate a report of my work"

  @lightweight
  Scenario: Student does not see report link if student report is disabled
    When the student report is disabled for the activity "simple activity"
    When I login with username: davy
    Then I should not see "Generate a report of my work"
    And I should not see "Last run"
    And run the activity
    And choose "Choice 1"
    And I press "Submit"
    Then I should see "Last run"
    And I should not see "Generate a report of my work"
    
