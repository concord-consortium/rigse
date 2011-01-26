Feature: Investigations can be sorted
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
      | name    | user      | offerings_count | created_at                      | publication_status  |
      | Newest  | teacher   | 5               | Wed Jan 26 12:00:00 -0500 2011  | published           |
      | Medium  | teacher   | 10              | Wed Jan 23 12:00:00 -0500 2011  | published           |
      | Oldest  | teacher   | 20              | Wed Jan 20 12:00:00 -0500 2011  | published           |
    And I login with username: teacher password: teacher
    
  @selenium
  Scenario: The investigations list can be sorted by name
    When I sort investigations by "name ASC"
    Then "Medium" should appear before "Newest"
    And "Newest" should appear before "Oldest"

  @selenium
  Scenario: The investigations list can be sorted by date created
    When I sort investigations by "created_at DESC"
    Then "Newest" should appear before "Medium"
    And "Medium" should appear before "Oldest"
    
  @selenium
  Scenario: The investigations list can be sorted by offerings count
    When I sort investigations by "offerings_count DESC"
    Then "Oldest" should appear before "Medium"
    And "Medium" should appear before "Newest"
    