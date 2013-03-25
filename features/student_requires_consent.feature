Feature: Student must give consent for research study

  when a student registered by a teacher logs in
  so that the project safely can do research on the student data
  the student shouldn't be able to do anything until they have consented or not

  Background: portal configured with student consent
    Given The default project and jnlp resources exist using factories
    And the default project has student consent enabled
    And the database has been seeded

  @javascript
  Scenario: Teacher signs up a student, student them must give consent on logging in
    Given the following classes exist:
          | name       | teacher | semester |
          | My Class   | teacher | Fall     |
    And the classes "My Class" are in a school named "VJTI"
    And I am logged in with the username teacher
    And I am on "Student Roster" page for "My Class"
    And I follow "Register and add new student"
    And I should see "Register and Add New Student"
    And I should not see "Your age"
    Then I fill in the following:
      | user_first_name            | Example  |
      | user_last_name             | Student  |
      | user_password              | password |
      | user_password_confirmation | password |
    And I press "Submit"
    And I log out
    And I login with username: estudent password: password
    Then I should see "Your age"
    And I choose "user_of_consenting_age_true"
    And I choose "user_have_consent_true"
    And I press "Submit"
    Then I should not see "Your age"
    And I log out
    And I login with username: estudent password: password
    Then I should not see "Your age"
    
    