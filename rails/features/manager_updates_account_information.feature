Feature: A manager updates account information for another user

  In order to correct mistakes a user has made
  As a Manager
  I want to update a users account information

  Background:
    Given The default settings exist using factories
    And the database has been seeded

  Scenario Outline: Managers can change a users email address
    When I am logged in with the username mymanager
    And I am on the user preferences page for the user "<username>"
    Then I should see "User Preferences"
    When I fill in "user_email" with "<changed_email>"
    And I press "Save"
    When I am on the user preferences page for the user "<username>"
    Then I should see "User Preferences"
    And the "user_email" field should contain "<changed_email>"

    Examples:
      | username | changed_email          |
      | student  | test1@mailintator.com  |
      | teacher  | test2@mailintator.com  |

  @javascript
  Scenario Outline: Managers can change a users password
    When I am logged in with the username mymanager
    And I am on the user list page
    And I click "View/Manage" for user: "<userlogin>"
    And I click "Reset Password" for user: "<userlogin>"
    Then I should see "Password for <username> (<userlogin>)"
    When I fill in "user_reset_password_password" with "<new_password>"
    And I fill in "user_reset_password_password_confirmation" with "<new_password>"
    And I press "Save"
    Then I should be on user list
    When I log out
    And I login with username: <userlogin> password: <new_password>
    Then I should see "Welcome"
    And I should see "SETTINGS"

    Examples:
      | username      | userlogin | new_password |
      | John Nash     | teacher   | buzbixbez    |

  @javascript
  Scenario: Managers can activate users
    When there is an unactivated user named "justsignedup"
    And I am logged in with the username mymanager
    And I am on the user list page
    And I look for the user by searching "justsignedup"
    And I should see "justsignedup"
    And I activate the user from user list by searching "justsignedup"
    Then I should be on the user list page
    And I should see "Activation of user, joe ( justsignedup ) complete."
