@javascript
Feature: Student views resource page

  In order see the resource page assigned to me
  As a student
  I want to open it

  Background:
    And I assign the resource page "NewestResource" to the class "My Class"

  Scenario: Student opens resource page
    And I am logged in with the username student
    And I am on the class page for "My Class"
    And run the resource page
    Then I should see "NewestResource"
