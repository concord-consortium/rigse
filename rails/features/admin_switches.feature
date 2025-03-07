Feature: Admin switches to a different user

  In order to see the portal as other users do without knowing their passwords
  As an admin
  I want to switch to a different user

  Background:
    Given The default settings exist using factories
    And the database has been seeded
    And an admin user named "Joe Admin" with username "j_admin" exists
    And a student user named "Joe Switchuser" exists

  @javascript
  Scenario: Admin switches to student
    When I am logged in with the username j_admin
    And I am on the user list page
    Then I should see "Welcome,"
    And I should see "Joe Admin"
    And I switch to "Joe Switchuser" in the user list by searching "Switchuser"
    Then I should see "Welcome,"
    And I should see "Joe Switchuser"

  @javascript
  Scenario: Admin switches back to admin
    When I am logged in with the username j_admin
    And I am on the user list page
    And I switch to "Joe Switchuser" in the user list by searching "Switchuser"
    Then I should see "Welcome,"
    And I should see "Joe Switchuser"
    And I follow "Switch back"
    And I am on the getting started page
    Then I should see "Welcome,"
    And I should see "Joe Admin"
