Feature: A manager updates account information for another user

  In order to correct mistakes a user has made
  As a Manager
  I want to update a users account information

  Background:
    Given The default project and jnlp resources exist using factories

  @javascript
  Scenario Outline: Managers can change a users email address
    Given the following teachers exist:
      | login   | password     | email               |
      | teacher | teacher      | bademail@noplace.com|

    And the following students exist:
      | login   | password     | email                  |
      | student | student      | student@mailinator.com |

    And the following users exist:
      | login     | password   | roles           |
      | mymanager | mymanager  | manager         |
    When I log out
    And I login with username: mymanager password: mymanager
    And I am on the user preferences page for the user "<username>"
    Then I should see "User Preferences"
    And I should see "<username>"
    And I should see the xpath "//input[@id='user_email']"
    When I fill in "<changed_email>" within "user_email"
    And I press "Save"
    Then I should be on the user list page
    When I am on the user preferences page for the user "<username>"
    Then I should see "User Preferences"
    And I should see "<username>"
    And I should see "<changed_emal>"

    Examples:
      | username | changed_email          |
      | student  | test1@mailintator.com  |
      | teacher  | test2@mailintator.com  |

