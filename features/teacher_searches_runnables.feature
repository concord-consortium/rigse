Feature: Investigations can be searched
  So I can find an investigation more efficiently
  As a teacher
  I want to sort the investigation list so that
  I can assign an investigation to my class

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following investigations exist:
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
          | Good a          | teacher | 5               | published          | 
          | Good b          | teacher | 5               | published          | 
          | Good c          | teacher | 5               | published          | 
          | Good d          | teacher | 5               | published          | 
    And I login with username: teacher password: teacher

  @selenium @itsisu-todo
  Scenario: looking at the first page of runnable investigations
    When I am on the class page for "My Class"
    Then There should be 20 investigations displayed
    And  "Good" should not be displayed in the investigations list
    And  I should see "Next" within "#offering_list"

  @selenium @itsisu-todo
  Scenario: looking at the second page of runnable investigations
    When I am on the class page for "My Class"
    And I click on the next page of results
    Then I should still be on the class page for "My Class"
    Then  "Good a" should be displayed in the investigations list

  @selenium @itsisu-todo
  Scenario:  searching through the list of runnable investigations
    When I visit the class page for "My Class"
    Then I enter "Investigation" in the search box
    And I wait for all pending requests to complete
    Then There should be 20 investigations displayed
    And  I should see "Next" within "#offering_list"
    When I click on the next page of results
    Then I should still be on the class page for "My Class"
    And  I should see "Previous" within "#offering_list"





