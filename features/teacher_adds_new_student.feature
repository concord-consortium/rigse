Feature: Teacher adds a new student

  As a teacher
  I should be able to add a new student
  In order to assign students to the class
  
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following students exist:
      | login   | password | first_name | last_name |
      | student | student  | Alfred     | Robert    |
    And the following teachers exist:
      | login   | password | first_name | last_name |
      | teacher | teacher  | John       | Nash      |
    And  the teachers "teacher" are in a school named "Harvard"
    And the following classes exist:
      | name       | teacher | semester |
      | My Class   | teacher | Fall     |
      | My Class 2 | teacher | Fall     |
    And the classes "My Class,My Class 2" are in a school named "Harvard"
    And I am logged in with the username teacher
    
    
  @javascript
  Scenario: Teacher can add a registered user
    When the student "student" belongs to class "My Class 2"
    And I am on "Student Roster" page for "My Class"
    And I follow "Search for registered student."
    And I should see "Robert, Alfred"
    And I select "Robert, Alfred ( student )" from the html dropdown "student_id_selector"
    And I should see "Robert, Alfred"
    And I press "Add"
    Then I should see "Robert, Alfred"
    
    
  @javascript
  Scenario: Teacher can add an unregistered user
    When the student "student" belongs to class "My Class"
    And the student "student" belongs to class "My Class 2"
    And I am on "Student Roster" page for "My Class"
    And I follow "Register and add new student"
    And I should see "Add and Register New Student"
    And I fill in the following:
      | user_first_name            | John   |
      | user_last_name             | Albert |
      | user_password              | albert |
      | user_password_confirmation | albert |
    And I press "Submit"
    And I should see "You have successfully registered John Albert with the username jalbert." within the popup
    And I press "Close" within the popup
    Then I should see "Albert, John"
    
    
  @javascript
  Scenario: Teacher adds another student from the pop up
    When the student "student" belongs to class "My Class"
    And the student "student" belongs to class "My Class 2"
    And I am on "Student Roster" page for "My Class"
    And I follow "Register and add new student"
    And I should see "Add and Register New Student"
    And I fill in the following:
      | user_first_name            | John   |
      | user_last_name             | Albert |
      | user_password              | albert |
      | user_password_confirmation | albert |
    And I press "Submit"
    And I should see "You have successfully registered John Albert with the username jalbert." within the popup
    And I press "Add Another" within the popup
    Then I should see "First Name:"
    
    