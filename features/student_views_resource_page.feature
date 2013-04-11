@javascript
Feature: Student views resource page

  In order see the resource page assigned to me
  As a student
  I want to open it

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded 
    And I am logged in with the username teacher
    And I am on the class page for "My Class"
    And I assign the resource page "NewestResource" to the class "My Class"
    And I log out

  @javascript
  Scenario: Student opens resource page
    And I am logged in with the username student
    And I am on the class page for "My Class"
    And run the resource page
    Then I should see "NewestResource"
