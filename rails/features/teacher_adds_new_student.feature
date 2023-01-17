Feature: Teacher adds a new student

  As a teacher
  I should be able to add a new student
  In order to assign students to the class


  Background:
    Given The default settings exist using factories
    And the database has been seeded
    And the classes "Mathematics,Physics" are in a school named "Harvard"


  @javascript
  Scenario: Teacher can add a registered user
    When the student "student" belongs to class "Physics"
    When I login with username: teacher
    And I am on "Student Roster" page for "Mathematics"
    And I select "Robert, Alfred ( student )" from the select named "student_id_selector"
    And I should see "Robert, Alfred"
    And I press "Add"
    Then I should see "Robert, Alfred" within the student list on the student roster page


  @javascript
  Scenario: Teacher can add an unregistered user
    When the student "student" belongs to class "Mathematics"
    And the student "student" belongs to class "Physics"
    And I login with username: teacher
    And I am on "Student Roster" page for "Mathematics"
    And I click the span "Register & Add New Student"
    And I should see "Register & Add New Student"
    And I fill in the following:
      | firstName            | John   |
      | lastName             | Albert |
      | password             | albert |
      | passwordConfirmation | albert |
    And I press "Submit"
    Then I should see "Albert, John" within the student list on the student roster page


  @javascript
  Scenario: Teacher adds another student from the pop up
    When the student "student" belongs to class "Mathematics"
    And the student "student" belongs to class "Physics"
    And I login with username: teacher
    And I am on "Student Roster" page for "Mathematics"
    And I click the span "Register & Add New Student"
    And I should see "Register & Add New Student"
    And I fill in the following:
      | firstName            | John   |
      | lastName             | Albert |
      | password             | albert |
      | passwordConfirmation | albert |
    And I press "Submit"

  #@javascript
  #Scenario: With the default class enabled, teachers cannot directly add existing students
  # Given the option to allow default classes is enabled
  #  When the student "student" belongs to class "Physics"
  #  When I login with username: teacher
  #  And I am on "Student Roster" page for "Mathematics"
  # Then I should see "If a student already has an account, ask the student to enter the Class Word above"
  #  And I should not see "Search for registered student"
