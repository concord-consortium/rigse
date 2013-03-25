Feature: Student resets passwordAnd

  In order to log in after I forgot my old password
  As a student
  I want to reset my password

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    
  @javascript
  Scenario: Passwords can not be blank
    When the student "student" has security questions set
    And I am on the forgot password page
    When I fill in "login" with "student" within content box in change password page
    And I press "Submit"
    Then I should see "Security Questions"
    When I fill in "security_questions[question0][answer]" with "red"
    When I fill in "security_questions[question1][answer]" with "pizza"
    When I fill in "security_questions[question2][answer]" with "chocolate"
    And I press "Submit"
    Then I should see "Please enter a new password and confirm it."
    When I press "Submit"
    Then I should see "Your password could not be changed."
    And I should see "Password can't be blank"
