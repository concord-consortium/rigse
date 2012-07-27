Feature: Teachers can drag-drop offerings to reposition them on the class summary page
  
  As a teacher
  I want to drag and drop the offerings
  In order to sort the offerings
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password   | first_name | last_name |
      | teacher  | teacher    | John       | Nash      |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the following students exist:
      | login     | password |
      | student   | student  |
    And the following offerings exist
      | name                       |
      | Lumped circuit abstraction |
      | static discipline          |
      | Non Linear Devices         |
    And I login with username: teacher
    And the student "student" belongs to class "My Class"
    And I am on the class page for "My Class"
    And I move the offering named "Non Linear Devices" to the top of the list on the class summary page
    
    
  @javascript
  Scenario: Teacher should be able to see the changes on the class summary page
    When I am on the class page for "My Class"
    Then the offering named "Non Linear Devices" should be the first on the list on the class summary page
    
    
  @javascript
  Scenario: Teacher should be able to see the changes on the class edit page
    When I am on "the class edit page for "My Class""
    Then "Non Linear Devices" should be the first on the list with id "sortable"
    
    
  @javascript
  Scenario: Teacher should be able to see the changes on the Materials page
    When I am on Instructional Materials page for "My Class"
    Then I should see "Non Linear Devices" within the tab block for Instructional Materials
    And I should see "Investigation: Non Linear Devices"
    
    
  @javascript
  Scenario: Students should be able to see the changes on the class summary page
    When I login with username: student
    And I am on the class page for "My Class"
    Then "Non Linear Devices" should appear before "Lumped circuit abstraction"
    
    