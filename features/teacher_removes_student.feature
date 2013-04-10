Feature: Teacher removes a student
  
  In order to  keep correct students assigned to the class
  As a teacher
  I should be able to remove a student
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    
    
  @javascript
  Scenario: Teacher removes a student
    When the student "student" belongs to class "Class_with_no_students"
    And I login with username: teacher password: password
    And I am on "Student Roster" page for "Class_with_no_students"
    And I accept the upcoming javascript confirm box
    When I follow "Remove Student"
    Then I should see "No students registered for this class yet."
    
    