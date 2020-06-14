Feature: Admin views default class

  In order to setup site wide activities
  As an admin
  I want to view the default class

  Scenario: Admin views default class
    Given the default class is created
    And the database has been seeded
    And I am logged in with the username admin
    And go to the class page for "Default Class"
    Then I should see "Default Class"
    

