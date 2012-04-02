Feature: Pages can be assigned as offerings

  As a teacher
  I want to assign a Page as an offering in a class

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following page exists:
      | name    | user    | publication_status |
      | My Page | teacher | published          |
    And I am logged in with the username teacher

  @javascript
  Scenario: Pages can be assigned by a Teacher to a class
    When I am on the class page for "My Class"
    
    And I assign the page "My Page" to the class "My Class"
    # this can fail because it doesn't wait for the request to finish
    Then I wait 1 second
    Then the page named "My Page" should have "offerings_count" equal to "1"
