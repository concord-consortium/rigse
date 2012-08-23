Feature: Teacher can search study materials

  As a teacher
  I should be able to search study materials
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
      | Set Theory             | author | published          | Set Theory decay is a great subject             |
      | Mechanics              | author | published          | Mechanics is a great subject                    |
      | Geometry               | author | published          | Triangle is a great subject                     |
      | integration calculus   | author | published          | integration calculus is a great subject         |
      | differential calculus  | author | published          | differential calculus decay is a great subject  |
      | differential equations | author | published          | differential equations is a great subject       |
      | organic chemistry      | author | published          | organic chemistry decay is a great subject      |
      | inorganic chemistry    | author | published          | inorganic chemistry decay is a great subject    |
      | graph theory           | author | published          | graph theory is a great subject                 |
      | radar theory           | author | published          | radar theory is a great subject                 |
    And the following activities for the above investigations exist:
      | name                        | investigation | user    | publication_status | description                            |
      | Radioactive decay           | Radioactivity | author  | published          | Nuclear Energy is a great material     |
      | Gama Rays                   | Radioactivity | author  | published          | Gama Rays is a great material          |
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
    And the investigation "Digestive System" with activity "Bile Juice" belongs to domain "Biological Science" and has grade "10-11"
    
    And the investigation "A Weather Underground" with activity "A heat spontaneously" belongs to probe "Temperature"
    And I login with username: teacher password: teacher
    And I am on the search instructional materials page"
    
    
  @javascript
  Scenario: Teacher can filter search results
    Then I should be able to filter the search results on the basis of domains and grades on the search instructional materials page
    And I should be able to filter the search results on the basis of probes on the search instructional materials page
    
    
  Scenario: Anonymous user can not assign study materials to the class
    When I log out
    And I go to the search instructional materials page
    Then I should not be able to assign materials on the search instructional materials page
    
    
  Scenario: Anonymous user can preview
    When I log out
    And I go to the search instructional materials page
    Then I preview materials on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can sort search/filter results
    Then I should be able to sort search and filter results on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can see search suggestions
    When I enter search text "Radioactivity" on the search instructional materials page
    Then I should see search suggestions for "Radioactivity" on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can search study materials
    When I search study material "Venn Diagram" on the search instructional materials page
    Then I should see search results for "Venn Diagram" on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can group search study materials
    Then I should be able to see grouped search results on the search instructional materials page
    
    
  @javascript
  Scenario: Search results should be paginated
    When the count of a search result is greater than the page size on the search instructional materials page
    Then the search results should be paginated on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can assign investigations and activites to a class
    Then I can assign investigations and activities to a class on the search instructional materials page
    
    
  Scenario: Teacher can preview investigations
    Then I can preview investigations on the search instructional materials page
    
    
  Scenario: Teacher can preview activities
    Then I can preview activities on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can see number classes to which instructional materials are assigned
    Then I should be able to see number classes to which instructional materials are assigned on the search instructional materials page
    
    