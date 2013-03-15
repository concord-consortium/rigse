Feature: Teacher removes a student
  
  In order to  keep correct students assigned to the class
  As a teacher
  I should be able to remove a student
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following multiple choice questions exists:
      | prompt | answers | correct_answer |
      | a      | a,b,c   | a              |
    And there is an image question with the prompt "image_q"
    And the following investigations with multiple choices exist:
      | investigation        | activity       | section   | page   | multiple_choices | image_questions | user      | activity_teacher_only |
      | Aerodynamics         | Air activity   | section a | page 1 | a                | image_q         | teacher   | false                 |
    And the following assignments exist:
      | type          | name                 | class                  |
      | investigation | Aerodynamics         | class_with_no_students |
      
      
  @javascript
  Scenario: Teacher removes a student
    When the student "student" belongs to class "class_with_no_students"
    And I login with username: teacher password: password
    And I am on "Student Roster" page for "class_with_no_students"
    And I accept the upcoming javascript confirm box
    When I follow "Remove Student"
    Then I should see "No students registered for this class yet."
    
    