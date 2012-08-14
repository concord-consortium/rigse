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
      | name              | user   | publication_status |
      | Radioactivity     | author | published          |
      | Set Theory        | author | published          |
      | Mechanics         | author | published          |
      | Geometry          | author | published          |
    And the following activities for the above investigations exist:
      | name                        | investigation | user    | publication_status |
      | Radioactive decay           | Radioactivity | author  | published          |
      | Gama Rays                   | Radioactivity | author  | published          |
      | Venn Diagram                | Set Theory    | author  | published          |
      | operations on sets          | Set Theory    | author  | published          |
      | Fluid Mechanics             | Mechanics     | author  | published          |
      | Geometry                    | Geometry      | author  | published          |
      | intersecting lines          | Geometry      | author  | published          |
      | parallel lines              | Geometry      | author  | published          |
      | graphs and lines            | Geometry      | author  | published          |
    And the following classes exist:
      | name        | teacher    | class_word |
      | Physics     | teacher    | phy        |
      | Chemistry   | teacher    | chem       |
      | Mathematics | teacher    | math       |
      | Biology     | teacher    | bio        |
      | Geography   | teacher    | geo        |
   And I login with username: teacher password: teacher
   And I am on the search page
   

  @javascript
  Scenario: Teacher can can sort search/filter results
    Then I should be able to sort search and filter results

   
  @javascript
  Scenario: Teacher can see search suggestions
    When I enter search text "Radioactivity"
    Then I should see search suggestions for "Radioactivity"
    
 
  @javascript
  Scenario: Teacher can search study materials
    When I search study material "Venn Diagram"
    Then I should see search results for "Venn Diagram"
    
    

  
  