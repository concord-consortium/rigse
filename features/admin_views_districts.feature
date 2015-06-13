Feature: Admin views districts

  In order to know which districts have registered
  As the site administrator
  I want to view the districts
  
  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username admin

  Scenario: admin see a list of districts
    When I am on the districts page
    Then I should see the default district
    And I should see "create District"
    
  Scenario: admin creates a new district
    When I am on the districts page
    And I follow "create District"
    And I fill in "portal_district_name" with "Test District"
    And I select "WY" from "portal_district[state]"
    And press "Save"
    And I follow "Admin"
    And I follow "Districts"
    Then I should see "Test District"

  Scenario: admin does not see the classes inside the district because doing that clobbers the server
    Given there is an active class named "sample class" with a district
    When I am on the districts page
    Then I should not see "sample class"
    And I should not see "active classes"
