@javascript
Feature: Teacher can deactivate resource pages from a class
  So my class can move on to other things
  As a teacher
  I want to unassign resource pages from a class
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    And I am on the class page for "My Class"
    And I assign the resource page "NewestResource" to the class "My Class"

  Scenario: Teacher can deactivate a resource page
    When I am on the class page for "My Class"
    And I follow "Deactivate" on the resource page "NewestResource" from the class "My Class"
    Then I should see "Activate"
    
    When I follow "Activate" on the resource page "NewestResource" from the class "My Class"
    Then I should see "Deactivate"