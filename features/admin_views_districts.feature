Feature: Admin views districts

  In order to know which districts have registered
  As the site administrator
  I want to view the districts
  
  Background:
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And follow "Districts"

  Scenario: admin see a list of districts
    Then I should see "Cross Project Portal-district"
    And I should see "create District"
    
  Scenario: admin creates a new district
    When I follow "create District"    
    And I fill in "portal_district_name" with "Test District"
    And press "Save"
    And I follow "Districts"
    Then I should see "Test District"
