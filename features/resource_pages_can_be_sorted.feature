Feature: Resource Pages can be sorted
  So I can find a resource page more efficiently
  As a teacher
  I want to sort the resource pages list
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
        
  @javascript
  Scenario: The resource pages list can be sorted by name
    When I sort resource pages by "name ASC"
    Then "Medium" should appear before "Newest"
    And "Newest" should appear before "Oldest"

  @javascript
  Scenario: The resource pages list can be sorted by date created
    When I sort resource pages by "created_at DESC"
    Then "Newest" should appear before "Medium"
    And "Medium" should appear before "Oldest"

  @javascript
  Scenario: The resource pages list can be sorted by offerings count
    When I sort resource pages by "offerings_count DESC"
    Then "Oldest" should appear before "Medium"
    And "Medium" should appear before "Newest"
