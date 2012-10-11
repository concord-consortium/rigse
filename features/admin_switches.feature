Feature: Admin switches to a different user

  In order to see the portal as other users do without knowing their passwords
  As an admin
  I want to switch to a different user
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following users exist:
     | login     | password  | roles   | first_name | last_name    |
     | student   | student   | member  | Joe        | Switchuser   |
     
  @javascript
  Scenario: Admin switches to student
    Given I login as an admin
    And I switch to "Joe Switchuser" in the user list by searching "Switchuser"
    Then I should see "Welcome Joe Switchuser"