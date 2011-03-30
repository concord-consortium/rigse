Feature: Pages can be assigned as offerings

  As a teacher
  I want to assign a Page as an offering in a class

  Background:
    Given The default project and jnlp resources exist using factories

  Scenario: Pages can be assigned to a class
    Given the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
		And the following page exists:
		  | name    | user    |
		  | My Page | teacher |
    When I assign the page "My Page" to the class "My Class"
    Then the page named "My Page" should have "offerings_count" equal to "1"
