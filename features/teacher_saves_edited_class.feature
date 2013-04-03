Feature: Teacher edits and saves class information

  As a teacher
  I want to edit my classes
  In order to keep my classes updated
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the classes "Mathematics" are in a school named "VJTI"
    And I am logged in with the username teacher
    And I am on "the class edit page for "Mathematics""
    
    
  @javascript
  Scenario: Teacher can see all the teachers which are in the class
    Then I should see "Peterson Taylor"
    And I should see "John Nash"
    
    
  @javascript
  Scenario: Teacher can see all the teachers which are not in the class
    When I follow Add Another Teacher drop down
    Then I should see "Fernandez, A. (albert)"
    
    
  @javascript
  Scenario: Teacher can add teacher from the class edit page
    When I select "Fernandez, A. (albert)" from the html dropdown "teacher_id_selector"
    And I press "Add"
    Then I should see "Albert Fernandez"
    
    
  @dialog
  @javascript
  Scenario: Teacher can remove teacher from the class edit page
    When I follow remove image for the teacher name "John Nash"
    And accept the dialog
    Then I should not see "John Nash"
    
    
  @javascript
  Scenario: Teacher saves class setup information
    When I fill in Class Name with "Basic Electronics"
    And I select Term "Fall" from the drop down
    And I fill Description with "This is a biology class"
    And I fill Class Word with "BETRX"
    And I uncheck investigation with label "Lumped circuit abstraction"
    And I move investigation named "Non Linear Devices" to the top of the list
    And I press "Save"
    Then I should be on Instructional Materials page for "Basic Electronics"
    And I should see "Class was successfully updated."
    
    
  Scenario: Teacher can see message if no materials are in the class
    When the following teacher and class mapping exists:
      | class_name                 | teacher   |
      | Class_with_no_assignment   | peterson  |
    And I am logged in with the username peterson
    And I am on "the class edit page for "Class_with_no_assignment""
    Then I should see "No materials assigned to this class."
    
    