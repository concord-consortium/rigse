Feature: Admin views default class

  In order to setup site wide activities
  As an admin
  I want to view the default class

  Scenario: Admin views default class
    Given the option to allow default classes is enabled

    # this is currently necessary to create the default class
    When I go to the student signup page
    And fill in the following:
      | user_first_name            | Example             |
      | user_last_name             | Student             |
      | user_password              | password            |
      | user_password_confirmation | password            |

    And login as an admin
    And go to the class page for "Default Class"
    Then I should see "Default Class"
    

