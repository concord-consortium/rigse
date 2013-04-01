Feature: Investigations can be searched
  So I can find an investigation more efficiently
  As a teacher
  I want to sort the investigations list

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following empty investigations exist:
        | name                    | user   | offerings_count | publication_status |
        | g Investigation         | author | 5               | published          |
        | h Investigation         | author | 5               | published          |
        | i Investigation         | author | 5               | published          |
        | j Investigation         | author | 5               | published          |
        | k Investigation         | author | 5               | published          |
        | l Investigation         | author | 5               | published          |
        | m Investigation         | author | 5               | published          |
        | n Investigation         | author | 5               | published          |
        | o Investigation         | author | 5               | published          |
        | p Investigation         | author | 5               | published          |
        | q Investigation         | author | 5               | published          |
        | r Investigation         | author | 10              | published          |
        | s Investigation         | author | 20              | published          |
        | t Investigation         | author | 20              | published          |
        | u Investigation         | author | 20              | published          |
        | v Investigation         | author | 20              | published          |
        | w Investigation         | author | 20              | published          |
        | x Investigation         | author | 20              | published          |
        | y Investigation         | author | 20              | published          |
        | z Investigation         | author | 20              | published          |
        | copy of a Investigation | author | 5               | draft              |
        | copy of b Investigation | author | 5               | draft              |
        | copy of c Investigation | author | 5               | draft              |
        | copy of d Investigation | author | 5               | draft              |
        | copy of e Investigation | author | 5               | draft              |
        | copy of f Investigation | author | 5               | draft              |
        | copy of g Investigation | author | 5               | draft              |
        | copy of h Investigation | author | 5               | draft              |
        | copy of i Investigation | author | 5               | draft              |
        | copy of j Investigation | author | 5               | draft              |
        | copy of k Investigation | author | 5               | draft              |
        | copy of l Investigation | author | 5               | draft              |
        | copy of m Investigation | author | 5               | draft              |
        | copy of n Investigation | author | 5               | draft              |
        | copy of o Investigation | author | 5               | draft              |
        | copy of p Investigation | author | 5               | draft              |
        | copy of q Investigation | author | 5               | draft              |
        | copy of r Investigation | author | 10              | draft              |
        | copy of s Investigation | author | 20              | draft              |
        | copy of t Investigation | author | 20              | draft              |
        | copy of u Investigation | author | 20              | draft              |
        | copy of v Investigation | author | 20              | draft              |
        | copy of w Investigation | author | 20              | draft              |
        | copy of x Investigation | author | 20              | draft              |
        | copy of y Investigation | author | 20              | draft              |
        | copy of z Investigation | author | 20              | draft              |
    Given I am logged in with the username teacher

  @javascript 
  Scenario: Default display of public investigations is name ASC
    When I browse public investigations
    Then There should be 20 investigations displayed
    And  "copy" should not be displayed in the investigations list
    And  "a Investigation" should appear before "b Investigation"

  @javascript
  Scenario: Changing the sort order
    When I sort investigations by "name DESC"
    Then There should be 20 investigations displayed
    And  "copy" should not be displayed in the investigations list
    And  "z Investigation" should appear before "y Investigation"   

  @javascript
  Scenario: Searching public investigations
    When I sort investigations by "name ASC"
    And I click on the next page of results
    Then There should be 20 investigations displayed
    And "copy" should not be displayed in the investigations list
    And I follow "Next →"
    And I should wait 2 seconds
    And "y Investigation" should appear before "z Investigation"

  @javascript
  Scenario:  browsing unpublished investigations
    When I browse draft investigations
    And I click on the next page of results
    Then There should be 20 investigations displayed
    And "copy" should be displayed in the investigations list

  @javascript
  Scenario: searching unpublished investigations
    When I browse draft investigations
    And I enter "copy of" in the search box
    And I wait for all pending requests to complete
    Then every investigation should contain "copy of"
