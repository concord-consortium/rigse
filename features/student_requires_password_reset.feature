Feature: Student requires a password reset

  So that I won't forget my password when my account was created for me
  As a student
  I am forced to change my password if my account was created for me.

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following students exist:
      | login   | password | require_password_reset |
      | student | student  | true                   |

  Scenario: Student forced to change password
    # And the student "student" has security questions set
    When I am logged in with the username student
    And I go to my home page
    Then I should be on the password reset page
    Then I should see "You must set a new password."

  Scenario: Student tries to navigate to their preferences
    When I am logged in with the username student
    When I go to my preferences
    Then I should be on the password reset page
    And I should see "You must set a new password."

  Scenario: Student updates password with errors
    When I am logged in with the username student
    And I am on my home page
    Then I should see "You must set a new password."
    When I fill in "user[password]" with "c"
    When I fill in "user[password_confirmation]" with "pizzaxyzzy"
    And I press "Submit"
    Then I should see "Your password could not be changed."

  Scenario: Student updates password
    When I am logged in with the username student
    And I am on my home page
    Then I should see "You must set a new password."
    When I fill in "user[password]" with "xyzzypizza"
    When I fill in "user[password_confirmation]" with "xyzzypizza"
    And I press "Submit"
    Then I should be on the login page
    And I should see "Password for student was successfully updated."

