Feature: A teacher creates a resource page
  As a Teacher
  I want to create a resource page
  So that students can see it.
      
  Background:
    Given The default project and jnlp resources exist using factories

  @selenium
  Scenario: The teacher creates a resource page
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And I login with username: teacher password: teacher
    When I go to the resource pages page
    And I follow "Create a new resource"
    Then I should see "New Resource"
    When I fill in the following:
      | resource_page[name] | Test Page |
    And I press "resource_page_submit"
    Then I should see "Resource was successfully created."
    
  
  @selenium
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
    And I login with username: teacherA password: teacher
    When I go to the resource pages page
    Then I should see "published page A"
    And I should see "published page B"
    And I should see "[PRIVATE] private page A"
    And I should not see "[PRIVATE] private page B"
    When I go to the resource pages with drafts page
    Then I should see "[DRAFT] draft page A"
    And I should see "[DRAFT] draft page B"
    
  @selenium
  Scenario: The teacher can view public and draft resource pages, and only their private ones
    Given the following teachers exist:
      | login         | password        |
      | teacherA      | teacher         |
    And the following resource pages exist:
      | name              | publication_status  | user      |
      | published page A  | published           | teacherA  |
      | draft page A      | draft               | teacherA  |
      | private page A    | private             | teacherA  |
    And I login with username: teacherA password: teacher
    Then I should see "published page A"
    And I should see "[PRIVATE] private page A"
    Then I should see "[DRAFT] draft page A"
    
  @selenium
  Scenario: The teacher can search for resource pages
    Given the following teachers exist:
      | login         | password        |
      | teacherA      | teacher         |
    And the following resource pages exist:
      | name            | publication_status  | user      |
      | Testing Page    | published           | teacherA  |
      | Testing Page 2  | draft               | teacherA  |
      | Demo Page       | published           | teacherA  |

    And I login with username: teacherA password: teacher
    When I search for a resource page named "Testing"
    Then I should see "Testing Page"
    And I should not see "Demo Page"
    And I should not see "Testing Page 2"
    When I search for a resource page including drafts named "Testing"
    Then I should see "Testing Page"
    And I should see "Testing Page 2"
    And I should not see "Demo Page"

