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
    And I follow "Create a new resource page"
    Then I should see "New Resource Page"
    When I fill in the following:
      | resource_page[name] | Test Page |
    And I press "resource_page_submit"
    Then I should see "Resource Page was successfully created."