Feature: Teacher removes a student
  
  In order to  keep correct students assigned to the class
  As a teacher
  I should be able to remove a student
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following classes exist:
      | name     | teacher | semester |
      | My Class | teacher | Fall     |
    And the classes "My Class" are in a school named "VJTI"
    And the student "student" belongs to class "My Class"
    
    
  @javascript
  Scenario: Teacher removes a student
    Given I login with username: teacher password: teacher
    And I am on "Student Roster" page for "My Class"
    And I accept the upcoming javascript confirm box
    When I follow "Remove Student"
    Then I should see "No students registered for this class yet."
    
    