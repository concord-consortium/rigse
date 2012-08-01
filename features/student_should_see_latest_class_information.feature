Feature: Student should see latest class information
  
  In order to only work on active offerings
  As a student
  I should always see latest class information
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following students exist:
      | login     | password  |
      | student   | student   |
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
      | name                      |
      | Lumped circuit abstraction|
      | static discipline         |
      | Non Linear Devices        |
    And the student "student" belongs to class "My Class"
    And I am logged in with the username teacher
    And I am on "the class edit page for "My Class""
    And I fill in Class Name with "Basic Electronics"
    And I select Term "Fall" from the drop down
    And I fill Description with "This is a biology class"
    And I fill Class Word with "betrx"
    And I uncheck investigation with label "Lumped circuit abstraction"
    And I move investigation named "Non Linear Devices" to the top of the list
    And I press "Save"
    
    
  @javascript
  Scenario: Student should see the updated class name
    When I login with username: student
    Then I should see "Basic Electronics"
    
    
  @javascript
  Scenario: Student should see all the updated information of a class
    When I login with username: student
    And I follow "Basic Electronics"
    Then I should see "Semester: Fall"
    And I should see "Class Word: betrx"
    And I should see "This is a biology class"
    And I should not see "Lumped circuit abstraction"
    And I should see "Non Linear Devices"
    And I should see "static discipline"
    And the first investigation in the list should be "Non Linear Devices"
    
    