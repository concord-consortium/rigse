Feature: Teacher can reset a students password
  So my student can log in
  As a teacher
  I want to reset their password

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded

  @javascript
  Scenario: Teacher can reset their students passwords
    Given the default class is created
    And the student "student" is in the class "Class_with_no_students"
    And I am logged in with the username teacher
    And I am on "Student Roster" page for "Class_with_no_students"
    Then I should see "Change Password"
    When I click "Change Password"
    Then I should see "You must set a new password"
    When I fill in "password" with "new_password"
    And I fill in "confirm password" with "new_password"
    And I press "Submit"
    Then I should see "Class Name : Class_with_no_students"
    When I log out
    And I login with username: student password: new_password
    Then I should see "Signed in successfully."

