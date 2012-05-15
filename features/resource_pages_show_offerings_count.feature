Feature: Resource Pages show the offerings count
  So I can see how many times a resource page has been assigned
  As a teacher
  I want to see the offerings count

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And I am logged in with the username teacher

  @javascript
  Scenario: The resource pages list can show the offerings count
    Given the following resource pages exist:
      | name           | user    | offerings_count | created_at                     | publication_status |
      | NewestResource | teacher | 6               | Wed Jan 26 12:00:00 -0500 2011 | published          |
      | MediumResource | teacher | 11              | Wed Jan 23 12:00:00 -0500 2011 | published          |
      | OldestResource | teacher | 21              | Wed Jan 20 12:00:00 -0500 2011 | published          |
    When I show offerings count on the resource pages page
    Then I should see "assigned 6 times"
    And I should see "assigned 11 times"
    And I should see "assigned 21 times"
