Feature: Admin can work with projects

  In order to assign materials to projects
  As an admin
  I need to work with project objects

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I login as an admin

  Scenario: Admin accesses projects
    Given the default projects exist using factories
    When I am on the home page
    And I follow "Admin"
    And I follow "Projects"
    Then I should be on the projects index page
    And I should see "3 projects"
    And I should see "create Project"

  Scenario: Admin creates a new project
    When I am on the projects index page
    And I click "create Project"
    And I fill in "admin_project[name]" with "My new project"
    And I fill in "admin_project[landing_page_slug]" with "new-project"
    And I fill in "admin_project[landing_page_content]" with "<h1>New project FooBar!</h1>"
    And I press "Save"
    Then I should be on the projects index page
    And I should see "1 project"
    And I should see "Project was successfully created."
    And I should see "My new project"
    When I click "/new-project"
    Then I should be on the route /new-project
    And I should see "New project FooBar!"

  Scenario: Admin creates a new project providing invalid params
    When I am on the projects index page
    And I click "create Project"
    And I press "Save"
    And I should see "there are errors"
    And I should see "Name can't be blank"
    And I fill in "admin_project[name]" with "My new project"
    And I fill in "admin_project[landing_page_slug]" with "slug"
    And I press "Save"
    Then I should be on the projects index page
    And I should see "Project was successfully created."
    And I should see "My new project"
    When I click "create Project"
    And I fill in "admin_project[landing_page_slug]" with "slug"
    And I press "Save"
    Then I should see "there are errors"
    And I should see "Name can't be blank"
    And I should see "Landing page slug has already been taken"
    When I fill in "admin_project[landing_page_slug]" with "invalid/slug"
    And I press "Save"
    Then I should see "there are errors"
    And I should see "Name can't be blank"
    And I should see "Landing page slug only allows lower case letters, digits and '-' character"

  @javascript
  Scenario: Admin edits existing project
    Given the default projects exist using factories
    And I am on the projects index page
    And I click on the edit link for project "project 2"
    When I fill in "admin_project[name]" with "New project name"
    And I press "Save"
    Then I should see "New project name"

  @javascript
  Scenario: Admin edits existing project providing invalid params
    Given the default projects exist using factories
    And I am on the projects index page
    When I click on the edit link for project "project 2"
    And I fill in "admin_project[name]" with ""
    And I press "Save"
    Then I should see "there are errors"
    And I should see "Name can't be blank"
    When I fill in "admin_project[name]" with "new project 2"
    And I fill in "admin_project[landing_page_slug]" with "project-1"
    And I press "Save"
    Then I should see "there are errors"
    And I should see "Landing page slug has already been taken"

  @javascript
  Scenario: Admin adds materials to a project
    Given the default projects exist using factories
    And the following simple investigations exist:
      | name              | description           | user   |
      | testing fast cars | how fast can cars go? | author |
    When I am on the search instructional materials page
    And I search for "testing fast cars" on the search instructional materials page
    And I follow the "(portal settings)" link for the investigation "testing fast cars"
    Then I should see "Projects"
    And I should see "project 1"
    And I should see "project 2"
    And I should see "project 3"
    When I check "project 1"
    And I press "Save"
    # Now project filter should be visible on the search page
    And I am on the search instructional materials page
    Then I should see "Projects"
    Then I should see "project 1"

  @javascript
  Scenario: Admin filters search results based on projects
    Given the default projects exist using factories
    And the following investigations are assigned to projects:
      | name          | project   |
      | Radioactivity | project 1 |
      | Set Theory    | project 2 |
      | Mechanics     | project 2 |
    When I am on the search instructional materials page
    Then I should see "Projects"
    And I should see "project 1"
    And I should see "project 2"
    And I should not see "project 3"
    When I check "project_project 1"
    Then I should see "Radioactivity"
    And I should not see "Set Theory"
    And I should not see "Mechanics"
    When I uncheck "project_project 1"
    And I check "project_project 2"
    Then I should not see "Radioactivity"
    And I should see "Set Theory"
    And I should see "Mechanics"
