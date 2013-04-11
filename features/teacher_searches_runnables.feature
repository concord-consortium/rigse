Feature: Investigations can be searched
  So I can find an investigation more efficiently
  As a teacher
  I want to sort the investigation list so that
  I can assign an investigation to my class

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following empty investigations exist:
          | name            | user   | offerings_count | publication_status |
          | g Investigation | author | 5               | published          | 
          | h Investigation | author | 5               | published          | 
          | i Investigation | author | 5               | published          | 
          | u Investigation | author | 20              | published          | 
          | v Investigation | author | 20              | published          | 
          | w Investigation | author | 20              | published          | 
          | x Investigation | author | 20              | published          | 
          | y Investigation | author | 20              | published          | 
          | z Investigation | author | 20              | published          | 
          | x Good a        | author | 5               | published          | 
          | x Good b        | author | 5               | published          | 
          | x Good c        | author | 5               | published          | 
          | x Good d        | author | 5               | published          |
    And I am logged in with the username teacher

  @javascript
  Scenario: looking at the first page of runnable investigations
    When I am on the class page for "My Class"
    Then There should be 20 investigations displayed
    And "x Good" should not be displayed in the investigations list
    And I should see "Next" within "#offering_list"

  @javascript
  Scenario: looking at the second page of runnable investigations
    When I am on the class page for "My Class"
    And I click on the next page of results
    Then "x Good a" should be displayed in the investigations list
    And I should be on the class page for "My Class"



