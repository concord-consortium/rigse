Feature: Student should see latest class information
  
  In order to only work on active offerings
  As a student
  I should always see latest class information
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    And I am on the class edit page for "Mathematics"
    And I fill in Class Name with "Basic Electronics"
    And I select Term "Fall" from the drop down
    And I fill Description with "This is a biology class"
    And I fill Class Word with "betrx"
    And I uncheck investigation with label "Lumped circuit abstraction"
    And I press "Save"
    
    
  @javascript
  Scenario: Student should see the updated class name
    When I login with username: taylor
    Then I should see "Basic Electronics"
    
    
  Scenario: Student should see all the updated information of a class
    When I login with username: taylor
    And I follow "Basic Electronics"
    Then I should see "Semester: Fall"
    And I should see "Class Word: betrx"
    And I should not see "Lumped circuit abstraction"
    And I should see "Non Linear Devices"
    And I should see "Static discipline"
    
    