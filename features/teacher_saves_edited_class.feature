Feature: Teacher edits and saves class information
  
  As a teacher
  I want to edit my classes
  In order to keep my classes updated
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password   | first_name | last_name  |
      | teacher  | teacher    | John       | Nash       |
      | albert   | teacher    | Albert     | Einstien   |
    And  the teachers "teacher , albert" are in a school named "VJTI"
    And the following semesters exist:
      | name     | start_time          | end_time            |
      | Fall     | 2012-12-01 00:00:00 | 2012-03-01 23:59:59 |
      | Spring   | 2012-10-10 23:59:59 | 2013-03-31 23:59:59 |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the classes "My Class" are in a school named "VJTI"
    And the following offerings exist
      | name                       |
      | Lumped circuit abstraction |
      | static discipline          |
      | Non Linear Devices         |
      
      
  @javascript
  Scenario: Teacher saves class setup information
    Given I login with username: teacher password: teacher
    And I am on "the class edit page for "My Class""
    When I fill in Class Name with "Basic Electronics"
    And I select Term "Fall" from the drop down
    And I include a teacher named "Einstien, Albert"
    And I fill Description with "This is a biology class"
    And I fill Class Word with "BETRX"
    And I uncheck investigation with label "Lumped circuit abstraction"
    And I move investigation named "Non Linear Devices" to the top of the list
    And I press save button
    Then new data for the class should be saved
    
    