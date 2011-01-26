Feature: Resource Page index pages can be printed
  So I can take resource page data with me
  As a teacher
  I want to print the resource page index page
  
  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And I login with username: teacher password: teacher
    And the following resource pages exist:
      | name    | user      | offerings_count | created_at                      | publication_status  |
      | Newest  | teacher   | 6               | Wed Jan 26 12:00:00 -0500 2011  | published           |
      | Medium  | teacher   | 11              | Wed Jan 23 12:00:00 -0500 2011  | published           |
      | Oldest  | teacher   | 21              | Wed Jan 20 12:00:00 -0500 2011  | published           |

  @selenium
  Scenario: Teacher prints the listing of all resource pages
    When I am on the resource pages page
    Then I should see "Newest"
    And I should see "Medium"
    And I should see "Oldest"
    When I follow "printable view"
    Then I should be on the resource pages printable index page
    And I should see "Resources"
    And I should see "Usage Count"
    And I should see "Newest"
    And I should see "Medium"
    And I should see "Oldest"
    
  @selenium
  Scenario: Teacher prints the listing of a subset of resource page
    When I am on the resource pages like "New" page
    Then I should see "Newest"
    And I should not see "Medium"
    And I should not see "Oldest"
    When I follow "printable view"
    Then I should be on the resource pages printable index page
    And I should see "Resources"
    And I should see "Usage Count"
    And I should see "Newest"
    And I should not see "Medium"
    And I should not see "Oldest"
