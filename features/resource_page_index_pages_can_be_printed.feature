Feature: Resource Page index pages can be printed
  So I can take resource page data with me
  As a teacher
  I want to print the resource page index page
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    And the following resource pages exist:
      | name            | user      | offerings_count | created_at                      | publication_status  |
      | NewestResource  | teacher   | 6               | Wed Jan 26 12:00:00 -0500 2011  | published           |
      | MediumResource  | teacher   | 11              | Wed Jan 23 12:00:00 -0500 2011  | published           |
      | OldestResource  | teacher   | 21              | Wed Jan 20 12:00:00 -0500 2011  | published           |

  Scenario: Teacher prints the listing of all resource pages
    When I am on the resource pages page
    Then I should see "NewestResource"
    And I should see "MediumResource"
    And I should see "OldestResource"
    And I should see "printable view"
    And "printable-view" should have href like "printable_index"
    And the link to "printable-view" should have a target "_blank"
    When I am on the resource pages printable index page
    Then I should see "Resource Pages"
    And I should see "Usage Count"
    And I should see "NewestResource"
    And I should see "MediumResource"
    And I should see "OldestResource"
    
  Scenario: Teacher prints the listing of a subset of resource page
    When I try to go to the resource pages like "New" page
    Then I should see "NewestResource"
    And I should not see "MediumResource"
    And I should not see "OldestResource"
    And I should see "printable view"
    And "printable-view" should have href like "printable_index" with params "name=New"
    And the link to "printable-view" should have a target "_blank"
    When I am on the resource pages printable index page
    Then I should see "Resource Pages"
    And I should see "Usage Count"
    And I should see "NewestResource"
    And I should not see "MediumResource"
    And I should not see "OldestResource"
