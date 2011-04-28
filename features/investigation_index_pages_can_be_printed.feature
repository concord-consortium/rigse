Feature: Investigation index pages can be printed
  So I can take investigation data with me
  As a teacher
  I want to print the investigation index page

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And I login with username: teacher password: teacher
    And the following empty investigations exist:
      | name    | user      | offerings_count | created_at                      | publication_status  |
      | Newest  | teacher   | 5               | Wed Jan 26 12:00:00 -0500 2011  | published           |
      | Medium  | teacher   | 10              | Wed Jan 23 12:00:00 -0500 2011  | published           |
      | Oldest  | teacher   | 20              | Wed Jan 20 12:00:00 -0500 2011  | published           |

  Scenario: Teacher prints the listing of all investigations
    When I am on the investigations page
    Then I should see "Newest"
    And I should see "Medium"
    And I should see "Oldest"
    And I should see "printable view"
    And "printable-view" should have href like "printable_index"
    And the link to "printable-view" should have a target "_blank"
    When I am on the investigations printable index page
    Then I should see "Investigation"
    And I should see "Usage Count"
    And I should see "Newest"
    And I should see "Medium"
    And I should see "Oldest"

  Scenario: Teacher prints the listing of a subset of investigations
    When I am on the investigations like "New" page
    Then I should see "Newest"
    And I should not see "Medium"
    And I should not see "Oldest"
    And I should see "printable view"
    And "printable-view" should have href like "printable_index" with params "name=New"
    And the link to "printable-view" should have a target "_blank"
    When I am on the investigations printable index page
    Then I should see "Investigations"
    And I should see "Usage Count"
    And I should see "Newest"
    And I should not see "Medium"
    And I should not see "Oldest"
