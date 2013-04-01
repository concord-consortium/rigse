Feature: Teachers can drag-drop offerings to reposition them on the class summary page
  
  As a teacher
  I want to drag and drop the offerings
  In order to sort the offerings
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I login with username: teacher
    And I am on the class page for "Mathematics"
    And I should see "Non Linear Devices"
    And I move the offering named "Non Linear Devices" to the top of the list on the class summary page
    And I should wait 5 seconds
    And "Non Linear Devices" should appear before "Static discipline"
    
  @javascript
  Scenario: Teacher should be able to see the changes on the class summary page
    When I am on the class page for "Mathematics"
    Then the offering named "Non Linear Devices" should be the first on the list on the class summary page
    
    
  @javascript
  Scenario: Teacher should be able to see the changes on the class edit page
    When I am on "the class edit page for "Mathematics""
    Then "Non Linear Devices" should be the first on the list with id "sortable"
    
    
  @javascript
  Scenario: Teacher should be able to see the changes on the Materials page
    When I am on Instructional Materials page for "Mathematics"
    Then I should see "Non Linear Devices" within the tab block for Instructional Materials
    And I should see "Investigation: Non Linear Devices"
    
    
  @javascript
  Scenario: Students should be able to see the changes on the class summary page
    When I login with username: taylor
    And I am on the class page for "Mathematics"
    Then "Non Linear Devices" should appear before "Lumped circuit abstraction"
    
    