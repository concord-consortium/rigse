Feature: Teacher changes password of a student
  
  In order to update student login information
  As a teacher
  I should be able to change the password of a student
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the following teachers exist:
      | login    | password   | first_name | last_name  |
      | teacher  | teacher    | John       | Nash       |
    And  the teachers "teacher" are in a school named "VJTI"
    And the following classes exist:
      | name     | teacher | semester |
      | My Class | teacher | Fall     |
    And the classes "My Class" are in a school named "VJTI"
    And the student "student" belongs to class "My Class"
    
    
  @javascript
  Scenario: Teacher changes password of a student
    Given I login with username: teacher password: teacher
    And I am on "Student Roster" page for "My Class"
    When I follow "Change Password"
    Then I should see "You must set a new password"
    
    