Feature: Teacher can reset a students password
  So my student can log in
  As a teacher
  I want to reset their password

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |

  Scenario: Teacher can reset their students passwords
    Given the default class is created
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the student "student" is in the class "My Class"
    And I am logged in with the username teacher
    And I am on the class page for "My Class"
    Then I should see "Change Password"
    When I click "Change Password"
    Then I should see "You must set a new password"
    When I fill in "user_password" with "new_password"
    And I fill in "user_password_confirmation" with "new_password"
    And I press "Submit"
    Then I should see "Class: My Class"
    When I log out
    And I login with username: student password: new_password
    Then I should see "Logged in successfully"

