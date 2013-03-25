Feature: Investigations can be searched
  So I can find an investigation more efficiently
  As a teacher
  I want to sort the investigation list so that
  I can assign an investigation to my class

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following empty investigations exist:
          | name            | user    | offerings_count | publication_status | 
          | a Investigation | teacher | 5               | published          | 
          | b Investigation | teacher | 5               | published          | 
          | c Investigation | teacher | 5               | published          | 
          | d Investigation | teacher | 5               | published          | 
          | e Investigation | teacher | 5               | published          | 
          | f Investigation | teacher | 5               | published          | 
          | g Investigation | teacher | 5               | published          | 
          | h Investigation | teacher | 5               | published          | 
          | i Investigation | teacher | 5               | published          | 
          | j Investigation | teacher | 5               | published          | 
          | k Investigation | teacher | 5               | published          | 
          | l Investigation | teacher | 5               | published          | 
          | m Investigation | teacher | 5               | published          | 
          | n Investigation | teacher | 5               | published          | 
          | o Investigation | teacher | 5               | published          | 
          | p Investigation | teacher | 5               | published          | 
          | q Investigation | teacher | 5               | published          | 
          | r Investigation | teacher | 10              | published          | 
          | s Investigation | teacher | 20              | published          | 
          | t Investigation | teacher | 20              | published          | 
          | u Investigation | teacher | 20              | published          | 
          | v Investigation | teacher | 20              | published          | 
          | w Investigation | teacher | 20              | published          | 
          | x Investigation | teacher | 20              | published          | 
          | y Investigation | teacher | 20              | published          | 
          | z Investigation | teacher | 20              | published          | 
          | x Good a        | teacher | 5               | published          | 
          | x Good b        | teacher | 5               | published          | 
          | x Good c        | teacher | 5               | published          | 
          | x Good d        | teacher | 5               | published          | 
    And I am logged in with the username teacher

  @javascript
  Scenario: looking at the first page of runnable investigations
    When I am on the class page for "My Class"
    Then There should be 20 investigations displayed
    And  "x Good" should not be displayed in the investigations list
    And  I should see "Next" within "#offering_list"

  @javascript
  Scenario: looking at the second page of runnable investigations
    When I am on the class page for "My Class"
    And I click on the next page of results
    Then  "x Good a" should be displayed in the investigations list
    And I should be on the class page for "My Class"



