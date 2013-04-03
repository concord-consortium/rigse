Feature: Teacher reorders materials assigned to the class
  In order to present materials in a logical order to students
  the teacher
  should be able reorder them 
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded 
    
  @javascript
  Scenario: Teacher reorders materials and students sees them in the correct order
    When I am logged in with the username teacher
    And I am on the class edit page for "Mathematics"
    And I move investigation named "Non Linear Devices" to the top of the list
    And I press "Save"
    When I login with username: taylor
    And I follow "Mathematics"
    And I should see "Lumped circuit abstraction"
    And I should see "Non Linear Devices"
    And I should see "Static discipline"
    Then "Non Linear Devices" should appear before "Static discipline"
    
  @javascript
  Scenario: Teacher reorders materials with the default class feature enabled
    Given the default class is created
    And I am logged in with the username teacher
    When I am on the class page for "Mathematics"
    And the Investigation "Lumped circuit abstraction" is assigned to the class "Mathematics"
    And the Investigation "Static discipline" is assigned to the class "Mathematics"
    And the Investigation "Non Linear Devices" is assigned to the class "Mathematics"
    And I am on the class edit page for "Mathematics"
    And I move investigation named "Non Linear Devices" to the top of the list
    And I press "Save"
    When I login with username: taylor
    And I follow "Mathematics"
    And I should see "Lumped circuit abstraction"
    And I should see "Non Linear Devices"
    And I should see "Static discipline"
    Then "Non Linear Devices" should appear before "Static discipline"
    And "Static discipline" should appear before "Lumped circuit abstraction"
    
