Feature: An author deletes parts of an investigation
  As a Investigations author
  I want to delete parts of my investigation
  So that I can revise my investigation

  Background:
    Given The default project and jnlp resources exist using factories

  @dialog
  @javascript
  Scenario: The author deletes a page from a section
    Given the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    Given the following simple investigations exist:
      | name              | description           | user   |
      | testing fast cars | how fast can cars go? | author |

    And I am logged in with the username author
    And I show the first section of the "testing fast cars" investigation
    Then I should see "Page: testing fast cars"
    When I follow "delete"
    And accept the dialog
    Then I should not see "Page: testing fast cars"

  @dialog
  @javascript
  Scenario: The author deletes a element from a page
    Given the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    And the author "author" created an investigation named "Test" with text and a open response question
    And I am logged in with the username author
    And I show the first page of the "Test" investigation
    Then I should see "Text: "
    When I follow "delete text"
    And accept the dialog
    Then I should not see "Text: "
