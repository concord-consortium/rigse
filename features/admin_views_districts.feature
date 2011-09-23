Feature: Admin views districts

  In order to know which districts have registered
  As the site administrator
  I want to view the districts
  
  Background:
    Given The default project and jnlp resources exist using factories
    And I login as an admin

  Scenario: admin see a list of districts
    When follow "Districts"
    Then I should see the default district
    And I should see "create District"
    
  Scenario: admin creates a new district
    When follow "Districts"
    When I follow "create District"    
    And I fill in "portal_district_name" with "Test District"
    And press "Save"
    And I follow "Districts"
    Then I should see "Test District"

  Scenario: admin does not see the classes inside the district because doing that clobbers the server
    Given there is an active class named "sample class" within a district
    When I follow "Districts"
    Then I should not see "sample class"
    And I should not see "active classes"
