Feature: Investigations can be searched
  So I can find an investigation more efficiently
  As a teacher
  I want to sort the investigations list

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following investigations exist:
        | name                    | user    | offerings_count | publication_status |
        | a Investigation         | teacher | 5               | published          |
        | b Investigation         | teacher | 5               | published          |
        | c Investigation         | teacher | 5               | published          |
        | d Investigation         | teacher | 5               | published          |
        | e Investigation         | teacher | 5               | published          |
        | f Investigation         | teacher | 5               | published          |
        | g Investigation         | teacher | 5               | published          |
        | h Investigation         | teacher | 5               | published          |
        | i Investigation         | teacher | 5               | published          |
        | j Investigation         | teacher | 5               | published          |
        | k Investigation         | teacher | 5               | published          |
        | l Investigation         | teacher | 5               | published          |
        | m Investigation         | teacher | 5               | published          |
        | n Investigation         | teacher | 5               | published          |
        | o Investigation         | teacher | 5               | published          |
        | p Investigation         | teacher | 5               | published          |
        | q Investigation         | teacher | 5               | published          |
        | r Investigation         | teacher | 10              | published          |
        | s Investigation         | teacher | 20              | published          |
        | t Investigation         | teacher | 20              | published          |
        | u Investigation         | teacher | 20              | published          |
        | v Investigation         | teacher | 20              | published          |
        | w Investigation         | teacher | 20              | published          |
        | x Investigation         | teacher | 20              | published          |
        | y Investigation         | teacher | 20              | published          |
        | z Investigation         | teacher | 20              | published          |
        | copy of a Investigation | teacher | 5               | draft              |
        | copy of b Investigation | teacher | 5               | draft              |
        | copy of c Investigation | teacher | 5               | draft              |
        | copy of d Investigation | teacher | 5               | draft              |
        | copy of e Investigation | teacher | 5               | draft              |
        | copy of f Investigation | teacher | 5               | draft              |
        | copy of g Investigation | teacher | 5               | draft              |
        | copy of h Investigation | teacher | 5               | draft              |
        | copy of i Investigation | teacher | 5               | draft              |
        | copy of j Investigation | teacher | 5               | draft              |
        | copy of k Investigation | teacher | 5               | draft              |
        | copy of l Investigation | teacher | 5               | draft              |
        | copy of m Investigation | teacher | 5               | draft              |
        | copy of n Investigation | teacher | 5               | draft              |
        | copy of o Investigation | teacher | 5               | draft              |
        | copy of p Investigation | teacher | 5               | draft              |
        | copy of q Investigation | teacher | 5               | draft              |
        | copy of r Investigation | teacher | 10              | draft              |
        | copy of s Investigation | teacher | 20              | draft              |
        | copy of t Investigation | teacher | 20              | draft              |
        | copy of u Investigation | teacher | 20              | draft              |
        | copy of v Investigation | teacher | 20              | draft              |
        | copy of w Investigation | teacher | 20              | draft              |
        | copy of x Investigation | teacher | 20              | draft              |
        | copy of y Investigation | teacher | 20              | draft              |
        | copy of z Investigation | teacher | 20              | draft              |
    And I login with username: teacher password: teacher

  @selenium
  Scenario: Browsing public investigations
    When I sort investigations by "name ASC"
    Then There should be 20 investigations displayed
    And  "copy" should not be displayed in the investigations list
    And  "a Investigation" should appear before "b Investigation"

  @selenium
  Scenario: Searching public investigations
    When I sort investigations by "name ASC"
    And I click on the next page of results
    Then There should be 6 investigations displayed
    And  "copy" should not be displayed in the investigations list
    And "y Investigation" should appear before "z Investigation"

  @selenium
  Scenario:  browsing unpublished investigations
    When I browse draft investigations
    And I click on the next page of results
    Then There should be 20 investigations displayed
    And "copy" should be displayed in the investigations list

  @selenium
  Scenario: searching unpublished investigations
    When I browse draft investigations
    And I enter "copy of" in the search box
    And I wait for all pending requests to complete
    Then every investigation should contain "copy of"
