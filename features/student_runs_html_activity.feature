Feature: Student runs html activity
  In order to use an html activity
  As a student
  I want to "run" the activity

  Background:
    Given the most basic default project
    And the database has been seeded
    And a simple activity with a multiple choice exists
    And the activity "simple activity" is assigned to the class "My Class"
  
  @lightweight
  Scenario: Student runs html
    And I login with username: student
    And run the activity
    And I press "Submit"

  @javascript @lightweight @disable_adhoc_workgroups
  Scenario: Student runs html and teacher sees recent activity
    And I login with username: student
    And run the activity
    And I choose "a"
    And I press "Submit"
    And I login with username: teacher
    And I follow "Recent Activity"

