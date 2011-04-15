Feature: Teacher can deactivate resource pages from a class
  So my class can move on to other things
  As a teacher
  I want to unassign resource pages from a class
  
  Background:
    Given The default project and jnlp resources exist using factories
  
  Scenario: Teacher can deactivate a resource page
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following resource pages exist:
      | name          | user    |
      | Test Resource | teacher |
    When I assign the resource page "Test Resource" to the class "My Class"
    And I login with username: teacher password: teacher
    And I am on the class page for "My Class"
        
    And I follow "Deactivate" on the resource page "Test Resource" from the class "My Class"
    Then I should see "Activate"
    
    When I follow "Activate" on the resource page "Test Resource" from the class "My Class"
    Then I should see "Deactivate"