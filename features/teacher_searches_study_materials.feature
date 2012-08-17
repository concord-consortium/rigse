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
      | Radioactivity          | author | published          | Radioactivity is a great material               |
      | Set Theory             | author | published          | Set Theory decay is a great material            |
      | Mechanics              | author | published          | Mechanics decay is a great material             |
      | Geometry               | author | published          | Geometry decay is a great material              |
      | integration calculus   | author | published          | integration calculus is a great material        |
      | differential calculus  | author | published          | differential calculus decay is a great material |
      | differential equations | author | published          | differential equations is a great material      |
      | organic chemistry      | author | published          | organic chemistry decay is a great material     |
      | inorganic chemistry    | author | published          | inorganic chemistry decay is a great material   |
      | graph theory           | author | published          | graph theory is a great material                |
      | radar theory           | author | published          | radar theory is a great material                |
    And the following activities for the above investigations exist:
      | name                        | investigation | user    | publication_status | description                            |
      | Radioactive decay           | Radioactivity | author  | published          | Radioactive decay is a great material  |
      | Gama Rays                   | Radioactivity | author  | published          | Gama Rays is a great material          |
      | Venn Diagram                | Set Theory    | author  | published          | Venn Diagram is a great material       |
      | operations on sets          | Set Theory    | author  | published          | operations on sets is a great material |
      | Fluid Mechanics             | Mechanics     | author  | published          | Fluid Mechanics is a great material    |
      | Circular Motion             | Mechanics     | author  | published          | Circular Motion is a great material    |
      | Geometry                    | Geometry      | author  | published          | Geometry is a great material           |
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
   And I am on the search instruction material page
   


  @javascript
  Scenario: Anonymous user can not assign study materials to the class
    When I log out
    And I go to the search instruction material page
    And I assign materials on search instruction material page
    Then I should be on my home page
    And I should see "Please login or register as a teacher"
    
  
  Scenario: Anonymous user can preview
    When I log out
    And I go to the search instruction material page
    Then I preview materials
    
    
  @javascript
  Scenario: Teacher can can sort search/filter results
    Then I should be able to sort search and filter results on search instruction material page

  
  @javascript
  Scenario: Teacher can see search suggestions
    When I enter search text "Radioactivity" on search instruction material page
    Then I should see search suggestions for "Radioactivity" on search instruction material page
    
  
  @javascript
  Scenario: Teacher can search study materials
    When I search study material "Venn Diagram" on search instruction material page
    Then I should see search results for "Venn Diagram" on search instruction material page
    
    
  @wip
  Scenario: Teacher can use filter to search study materials
    Then I should be able to filter the search results on search instruction material page
    
  
  @javascript
  Scenario: search results should be paginated
    When the count of a search result is greater than the page size on search instruction material page
    Then the search results should be paginated on search instruction material page
    
  
  @javascript
  Scenario: Teacher can assign investigations and activites to the class
    Then I can assign investigations and activites to the class on search instruction material page
  
  
  Scenario: Teacher can preview investigations
    Then I can preview investigations on search instruction material page
 
  
  Scenario: Teacher can preview activities
    Then I can preview activities on search instruction material page