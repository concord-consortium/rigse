Feature: Teacher can search and filter instructional materials

  As a teacher
  I should be able to search and filter instructional materials
  In order to find suitable study materials for the class
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         | Nash      |
    And the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    And the following simple investigations exist:
      | name                   | user   | publication_status | description                                     |
      | Mechanics              | author | published          | Mechanics is a great subject                    |
      | Geometry               | author | published          | Triangle is a great subject                     |
      | differential calculus  | author | published          | differential calculus decay is a great subject  |
    And the following activities for the above investigations exist:
      | name                        | investigation | user    | publication_status | description                            |
      | Fluid Mechanics             | Mechanics     | author  | published          | Fluid Mechanics is a great material    |
      | Geometry                    | Geometry      | author  | published          | Triangle is a great material           |
    And the following classes exist:
      | name        | teacher    | class_word |
      | Physics     | teacher    | phy        |
      | Mathematics | teacher    | math       |
      | Geography   | teacher    | geo        |
    And I login with username: teacher password: teacher
    And I am on the search instructional materials page"
    
    
Scenario: Anonymous user can not assign instructional materials to the class
    When I log out
    And I go to the search instructional materials page
    And I follow assign to a class link for investigation "Geometry"
    Then I should be on the home page
    And I go to the search instructional materials page
    And I follow assign to a class link for activity "Fluid Mechanics"
    
    
  @dialog
  @javascript
  Scenario: Teacher can assign investigations to a class
    When I follow assign to a class link for investigation "Geometry"
    And I check "Mathematics"
    And I follow "Save"
    And accept the dialog
    And I go to the class page for "Mathematics"
    Then I should see "Geometry"
    
    
  @dialog
  @javascript
  Scenario: Teacher can assign activities to a class
    And I uncheck "Investigation"
    And I should wait 2 seconds
    And I check "Activity"
    And I should wait 2 seconds
    And I follow assign to a class link for activity "Fluid Mechanics"
    And "Mechanics" should appear before "Fluid Mechanics"
    And I check "Physics"
    And I follow "Save"
    And accept the dialog
    And I go to the class page for "Physics"
    And I should see "Fluid Mechanics"
    
    
  @javascript
  Scenario: Teacher can see number classes to which investigations are assigned
    When the Investigation "differential calculus" is assigned to the class "Physics"
    And the Investigation "differential calculus" is assigned to the class "Geography"
    And the Investigation "differential calculus" is assigned to the class "Mathematics"
    And I am on the search instructional materials page
    Then I should see "Used in 3 classes."
    
    
  @javascript
  Scenario: Teacher can see number classes to which investigations are assigned
    When the Activity "Geometry" is assigned to the class "Physics"
    And the Activity "Geometry" is assigned to the class "Geography"
    And the Activity "Geometry" is assigned to the class "Mathematics"
    And I am on the search instructional materials page'
    Then I should see "Used in 3 classes."
    
    