@javascript
Feature: Student views resource page

  In order see the resource page assigned to me
  As a student
  I want to open it

  Background:
    Given The default project and jnlp resources exist using factories
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the following resource pages exist:
      | name          | user    | publication_status |
      | Test Resource | teacher | published          |
    And the student "student" belongs to class "My Class"
    And I am logged in with the username teacher
    And I am on the class page for "My Class"
    And I assign the resource page "Test Resource" to the class "My Class"
    And I log out

  @javascript
  Scenario: Student opens resource page
    And I am logged in with the username student
    And I am on the class page for "My Class"
    Then I should see "Test Resource"

    When I follow "Run by Myself"
    Then I should see "Test Resource"
