Feature: Admin switches to a different user

  In order to see the portal as other users do without knowing their passwords
  As an admin
  I want to switch to a different user
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    
  @javascript
  Scenario: Admin switches to student
    When I login as an admin
    And I switch to "Joe Switchuser" in the user list by searching "Switchuser"
    Then I should see "Welcome Joe Switchuser"
    
  @javascript
  Scenario: Admin switches back to admin
    When I login as an admin
    And I switch to "Joe Switchuser" in the user list by searching "Switchuser"
    Then I should see "Welcome Joe Switchuser"
    And I follow "Switch Back"
    Then I should see "Welcome joe user"