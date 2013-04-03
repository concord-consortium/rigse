Feature: Resource Pages show the offerings count
  So I can see how many times a resource page has been assigned
  As a teacher
  I want to see the offerings count

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher

  @javascript
  Scenario: The resource pages list can show the offerings count
    When I show offerings count on the resource pages page
    Then I should see "assigned 6 times"
    And I should see "assigned 11 times"
    And I should see "assigned 21 times"
