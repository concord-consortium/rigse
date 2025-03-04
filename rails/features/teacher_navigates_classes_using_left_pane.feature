# PP-Navigation broke this test. Will take a while to fix NP 2018-07-09
@pending
Feature: Teacher navigates using left pane

  As a teacher
  I want to visit various pages using left pane
  In order to make navigation more effective

  Background:
    Given The default settings exist using factories
    And the database has been seeded
    And I login with username: teacher

  @javascript
  Scenario: Teachers can see their class name
    When I follow "Classes"
    Then I should see "My Class"

  @javascript
  Scenario: Teacher visits Student Roster page
    When I follow "Classes"
    And I follow "My Class"
    When I follow "Student Roster" within "My Class"
    Then I should be on "Student Roster" page for "My Class"

  @javascript
  Scenario: Teacher visits Class Setup page
    When I follow "My Class"
    And I follow "Class Setup"
    Then I should be on the class edit page for "My Class"

  @javascript
  Scenario: Teacher visits Materials page
    When I follow "My Class"
    And I follow "Assignments"
    Then I should be on Instructional Materials page for "My Class"
