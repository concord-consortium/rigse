Feature: A manager updates account information for another user

  In order to correct mistakes a user has made
  As a Manager
  I want to update a users account information

  Background:
    Given The default project and jnlp resources exist using factories

  # @javascript
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
    When I fill in "user_email" with "<changed_email>"
    And I press "Save"
    When I am on the user preferences page for the user "<username>"
    Then I should see "User Preferences"
    And the "user_email" field should contain "<changed_email>"

    Examples:
      | username | changed_email          |
      | student  | test1@mailintator.com  |
      | teacher  | test2@mailintator.com  |

  # @javascript
  Scenario Outline: Managers can change a users password
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
    And I am on the user list page
    And I click "Reset Password" for user: "<userlogin>"
    Then I should see "Password for <username> (<userlogin>)"
    When I fill in "user_password" with "<new_password>"
    And I fill in "user_password_confirmation" with "<new_password>"
    And I press "Submit"
    Then the location should be "http://www.example.com/users"
    When I log out
    And I login with username: <userlogin> password: <new_password>
    Then I should see "Logged in successfully"

    Examples:
      | username | userlogin | new_password |
      | joe user | student   | foobarbaz    |
      | joe user | teacher   | buzbixbez    |

