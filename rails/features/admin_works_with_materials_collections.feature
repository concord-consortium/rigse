Feature: Admin can work with materials collections

  In order to groups materials into collections
  As an admin
  I need to work with materials collection objects


  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username admin

  # the left menu is rendered by react-components
  @javascript
  Scenario: Admin accesses Materials Collections
    When I am on the home page
    And I follow "Admin"
    And I wait 1 second
    And I follow "Materials Collections"
    Then I should be on the materials collection index page
    And I should see "Displaying all 4 Materials Collections"
    And I should see "Create Materials Collection"

  Scenario: Admin creates new Materials Collection
    Given a project called "My Project"
    When I am on the materials collection index page
    And I click "create Materials Collection"
    Then I should see "(new) /materials_collection"
    When I fill in "materials_collection[name]" with "My new Collection"
    When I select "My Project" from "materials_collection[project_id]"
    And I fill in "materials_collection[description]" with "My new Description"
    And I press "Save"
    Then I should be on the materials collection index page
    And I should see "Materials Collection was successfully created."
    And I should see "My new Collection"


  @javascript
  Scenario: Admin views existing Materials Collection via the show link
    When I am on the materials collection index page
    And I click on the id link for materials collection "Collection 4"
    Then I should be on the show page for materials collection "Collection 4"

  Scenario: Admin edits existing Materials Collection
    When I am on the materials collection index page
    And I click on the edit link for materials collection "Collection 4"
    Then I should see "Materials Collection: Collection 4"
    When I fill in "materials_collection[name]" with "My new Collection edits"
    And I fill in "materials_collection[description]" with "My new Description"
    And I press "Save"
    Then I should see "My new Collection edits"

  @javascript @search
  Scenario: Admin adds materials to a Materials Collection
    Given the following simple investigations exist:
      | name              | description           | user   |
      | testing fast cars | how fast can cars go? | author |
    When I am on the search instructional materials page
    And I search for "testing fast cars" on the search instructional materials page
    And I follow the "Add to Collection" link for the material "testing fast cars"
    Then I should see "Select Collection(s)"
    And I should see "Collection 1"
    And I should see "Collection 4"
    And I should not see "Already assigned to the following collections"
    And I should be on the search instructional materials page
    When I check "Collection 1"
    And I click "Save"
    Then I should not see "Collection 1"
    And I should not see "Collection 4"
    And I should see "testing fast cars is assigned to the selected collection(s) successfully" within the lightbox in focus
    When I press "OK"
    And I follow the "Add to Collection" link for the investigation "testing fast cars"
    Then I should see "Select Collection(s)"
    And I should see "Already assigned to the following collection(s)"


  @javascript
  Scenario: Admin deletes existing Materials Collection
    When I am on the materials collection index page
    And I click on the delete link for materials collection "Collection 2"
    And I accept the dialog
    And I wait 1 second
    Then I should not see "Collection 2"

  @javascript
  Scenario: Admin cancels deleting existing Materials Collection
    When I am on the materials collection index page
    And I click on the delete link for materials collection "Collection 1"
    And I dismiss the dialog
    And I wait 1 second
    Then I should see "Collection 1"
