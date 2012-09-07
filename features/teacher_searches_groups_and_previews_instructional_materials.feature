Feature: Teacher can search instructional materials grouped by material type, sort and preview them.

  As a teacher
  I want to search instructional materials grouped by material type, sort and preview materials
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
      | Radioactivity          | author | published          | Nuclear Energy is a great subject               |
      | Set Theory             | author | published          | Set Theory is a great subject                   |
      | Mechanics              | author | published          | Mechanics is a great subject                    |
      | Geometry               | author | published          | Triangle is a great subject                     |
      | integral calculus      | author | published          | integral calculus is a great subject            |
      | differential calculus  | author | published          | differential calculus is a great subject        |
      | differential equations | author | published          | differential equations is a great subject       |
      | organic chemistry      | author | published          | organic chemistry is a great subject            |
      | inorganic chemistry    | author | published          | inorganic chemistry is a great subject          |
      | graph theory           | author | published          | graph theory is a great subject                 |
      | radar theory           | author | published          | radar theory is a great subject                 |
    And the following activities for the above investigations exist:
      | name                        | investigation | user    | publication_status | description                            |
      | Radioactive decay           | Radioactivity | author  | published          | Nuclear Energy is a great material     |
      | Gamma Rays                  | Radioactivity | author  | published          | Gamma Rays is a great material         |
      | Venn Diagram                | Set Theory    | author  | published          | Venn Diagram is a great material       |
      | operations on sets          | Set Theory    | author  | published          | operations on sets is a great material |
      | Fluid Mechanics             | Mechanics     | author  | published          | Fluid Mechanics is a great material    |
      | Circular Motion             | Mechanics     | author  | published          | Circular Motion is a great material    |
      | Geometry                    | Geometry      | author  | published          | Triangle is a great material           |
      | intersecting lines          | Geometry      | author  | published          | intersecting lines is a great material |
      | parallel lines              | Geometry      | author  | published          | parallel lines is a great material     |
      | graphs and lines            | Geometry      | author  | published          | parallel lines is a great material     |
      | circles                     | Geometry      | author  | published          | circles is a great material            |
      | boolean algebra             | Geometry      | author  | published          | boolean algebra is a great material    |
    And the following classes exist:
      | name        | teacher    | class_word |
      | Physics     | teacher    | phy        |
      | Chemistry   | teacher    | chem       |
      | Mathematics | teacher    | math       |
      | Biology     | teacher    | bio        |
      | Geography   | teacher    | geo        |
    And I login with username: teacher password: teacher
    And I am on the search instructional materials page
    
    
  Scenario: Anonymous user can preview investigation
    When I log out
    And I go to the search instructional materials page
    Then I should preview investigation "Geometry" on the search instructional materials page
    
    
  Scenario: Anonymous user can preview activity
    When I log out
    And I go to the search instructional materials page
    Then I should preview activity "differential calculus" on the search instructional materials page
    
    
  Scenario: Teacher can preview investigation
    Then I should preview investigation "Geometry" on the search instructional materials page
    
    
 Scenario: Teacher can preview activity
    Then I should preview activity "differential calculus" on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can see search suggestions
    When I enter search text "Radioactivity" on the search instructional materials page
    Then I should see search suggestions for "Radioactivity" on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can search instructional materials
    When I search study material "Venn Diagram" on the search instructional materials page
    Then I should see search results for "Venn Diagram" on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can sort search results alphabetically
    When I enter search text "lines" on the search instructional materials page
    And I press "GO"
    And I should wait 2 seconds
    And I follow "Alphabetical" in Sort By on the search instructional materials page
    Then "graphs and lines" should appear before "intersecting lines"
    And "intersecting lines" should appear before "parallel lines"
    And I enter search text "calculus" on the search instructional materials page
    And I press "GO"
    And I should wait 2 seconds
    And I follow "Alphabetical" in Sort By on the search instructional materials page
    Then "differential calculus" should appear before "integral calculus"
    
    
  @javascript
  Scenario: Teacher can sort search results for investigations on the basis of creation date
    When I create investigations "differential calculus" before "integral calculus" by date
    And I enter search text "calculus" on the search instructional materials page
    And I press "GO"
    And I follow "Oldest" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    Then "integral calculus" should appear before "differential calculus"
    And I follow "Newest" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    And "differential calculus" should appear before "integral calculus"
    
    
  @javascript
  Scenario: Teacher can sort search results for activities on the basis of creation date
    When I create activities "parallel lines" before "graphs and lines" by date
    And I enter search text "lines" on the search instructional materials page
    And I press "GO"
    And I follow "Oldest" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    Then "graphs and lines" should appear before "parallel lines"
    And I follow "Newest" in Sort By on the search instructional materials page
    And I should wait 4 seconds
    Then "parallel lines" should appear before "graphs and lines"
    
    
  @javascript
  Scenario: Teacher can sort search investigations on the basis of popularity
    When the Investigation "differential calculus" is assigned to the class "Physics"
    And the Investigation "differential calculus" is assigned to the class "Geography"
    And the Investigation "differential calculus" is assigned to the class "Mathematics"
    And the Investigation "integral calculus" is assigned to the class "Mathematics"
    And the Investigation "integral calculus" is assigned to the class "Geography"
    And I follow "Popularity" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    Then "differential calculus" should appear before "integral calculus"
    
    
  @javascript
  Scenario: Teacher can sort search activities on the basis of popularity
    When the Activity "intersecting lines" is assigned to the class "Physics"
    And the Activity "intersecting lines" is assigned to the class "Geography"
    And the Activity "intersecting lines" is assigned to the class "Mathematics"
    And the Activity "parallel lines" is assigned to the class "Mathematics"
    And the Activity "parallel lines" is assigned to the class "Geography"
    And I follow "Popularity" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    Then "intersecting lines" should appear before "parallel lines"
    
    
  @javascript
  Scenario: Teacher should be able to see grouped search results on the basis of material type
    When I enter search text "Geometry" on the search instructional materials page
    And I uncheck "Investigation"
    And I check "Activity"
    And I press "GO"
    And I should wait 2 seconds
    And I should see "Geometry"
    And I should see "Triangle is a great subject"
    And I should see "Triangle is a great material"
    And I should not see "Radioactivity"
    When I enter search text "Radioactivity" on the search instructional materials page
    And I check "Investigation"
    And I uncheck "Activity"
    And I press "GO"
    And I should wait 2 seconds
    Then I should see "Radioactivity"
    And I should see "Nuclear Energy is a great subject"
    And I should not see "Nuclear Energy is a great material"
    And I should not see "Geometry"
    
    
  @javascript
  Scenario: Search results should be paginated
    When I enter search text "is a great material" on the search instructional materials page
    And I press "GO"
    And I should wait 2 seconds
    Then the search results should be paginated on the search instructional materials page
    
    