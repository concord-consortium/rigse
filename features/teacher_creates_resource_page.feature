Feature: A teacher creates a resource page
  As a Teacher
  I want to create a resource page
  So that students can see it.

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded

  @javascript
  Scenario: The teacher creates a resource page
    When I am logged in with the username teacher
    When I go to the resource pages page
    And I follow "create Resource Page"
    Then I should see "New Resource"
    When I fill in the following:
      | resource_page[name] | Test Page |
    And I press "Create Resource page"
    Then I should see "Resource Page was successfully created."


  Scenario: The teacher can view public and draft resource pages, and only their private ones
    Given the following teachers exist:
      | login         | password        |
      | teacherA      | teacher         |
      | teacherB      | teacher         |
    And the following resource pages exist:
      | name              | publication_status  | user      |
      | published page A  | published           | teacherA  |
      | published page B  | published           | teacherB  |
      | draft page A      | draft               | teacherA  |
      | draft page B      | draft               | teacherB  |
      | private page A    | private             | teacherA  |
      | private page B    | private             | teacherB  |
    And I am logged in with the username teacherA
    When I go to the resource pages page
    Then I should see "published page A"
    And I should see "published page B"
    And I should see "private page A"
    And I should not see "private page B"
    When I try to go to the resource pages with drafts page
    Then I should see "draft page A"
    And I should see "draft page B"

  Scenario: The teacher can see their resource pages on the homepage
    Given the following teachers exist:
      | login         | password        |
      | teacherA      | teacher         |
    And the following resource pages exist:
      | name              | publication_status  | user      |
      | published page A  | published           | teacherA  |
      | draft page A      | draft               | teacherA  |
      | private page A    | private             | teacherA  |
    And I am logged in with the username teacherA
    When I am on the homepage
    Then I should see "published page A"
    And I should see "private page A"
    Then I should see "draft page A"

  Scenario: The teacher can search for resource pages
    Given the following teachers exist:
      | login         | password        |
      | teacherA      | teacher         |
      | teacherB      | teacher         |
    And the following resource pages exist:
      | name            | publication_status  | user      |
      | 1Testing Page   | published           | teacherA  |
      | 2Testing Page   | draft               | teacherA  |
      | Demo Page       | published           | teacherA  |
      | BTesting Page   | draft               | teacherB  |
      | BDemo Page      | published           | teacherB  |

    And I am logged in with the username teacherA
    When I search for a resource page named "Testing"
    Then I should see "1Testing Page"
    And I should see "2Testing Page"
    And I should not see "Demo Page"
    And I should not see "BDemo Page"
    And I should not see "BTesting Page"
    When I search for a resource page including drafts named "Testing"
    Then I should see "1Testing Page"
    And I should see "2Testing Page"
    And I should see "BTesting Page"
    And I should not see "Demo Page"
    And I should not see "BDemo Page"
