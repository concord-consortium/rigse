Feature: Teacher adds a new student

  As a teacher
  I should be able to add a new student
  In order to assign students to the class
  
  
  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And the classes "Mathematics,Physics" are in a school named "Harvard"
    
    
  @javascript
  Scenario: Teacher can add a registered user
    When the student "student" belongs to class "Physics"
    When I login with username: teacher
    And I am on "Student Roster" page for "Mathematics"
    And I follow "Search for registered student."
    And I should see "Robert, Alfred"
    And I select "Robert, Alfred ( student )" from the html dropdown "student_id_selector"
    And I should see "Robert, Alfred"
    And I press "Add"
    Then I should see "Robert, Alfred" within the student list on the student roster page
    
    
  @javascript
  Scenario: Teacher can add an unregistered user
    When the student "student" belongs to class "Mathematics"
    And the student "student" belongs to class "Physics"
    And I login with username: teacher
    And I am on "Student Roster" page for "Mathematics"
    And I follow "Register and add new student"
    And I should see "Register and Add New Student"
    And I fill in the following:
      | user_first_name            | John   |
      | user_last_name             | Albert |
      | user_password              | albert |
      | user_password_confirmation | albert |
    And I press "Submit"
    And I should see "You have successfully registered John Albert with the username jalbert." within the popup
    And I press "Close" within the popup
    Then I should see "Albert, John" within the student list on the student roster page
    
    
  @javascript
  Scenario: Teacher adds another student from the pop up
    When the student "student" belongs to class "Mathematics"
    And the student "student" belongs to class "Physics"
    And I login with username: teacher
    And I am on "Student Roster" page for "Mathematics"
    And I follow "Register and add new student"
    And I should see "Register and Add New Student"
    And I fill in the following:
      | user_first_name            | John   |
      | user_last_name             | Albert |
      | user_password              | albert |
      | user_password_confirmation | albert |
    And I press "Submit"
    And I should see "You have successfully registered John Albert with the username jalbert." within the popup
    And I press "Add Another" within the popup
    Then I should see "First Name:"

  @javascript
  Scenario: With the default class enabled, teachers cannot directly add existing students
    Given the option to allow default classes is enabled
    When the student "student" belongs to class "Physics"
    When I login with username: teacher
    And I am on "Student Roster" page for "Mathematics"
    Then I should see "If a student already has an account, ask the student to enter the Class Word above"
    And I should not see "Search for registered student"
