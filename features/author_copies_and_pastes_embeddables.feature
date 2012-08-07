Feature: An copies and pastes embeddables
  As a Investigations author
  I want to copy and paste embeddables
  So that I can create investigations more quickly

  Background:
    Given The default project and jnlp resources exist using factories

  @javascript
  Scenario: The author copies and pastes an embeddable
    Given the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    Given the following simple investigations exist:
      | name              | description           | user   |
      | testing fast cars | how fast can cars go? | author |

    And I am logged in with the username author
    When I show the first page of the "testing fast cars" investigation
    And I add a "Text" to the page
    Then I should see "content goes here ..."
    When I copy the embeddable "Text: content goes here ..."
    Then I should see "paste Text: content goes here ..."
    When I paste the embeddable "Text: content goes here ..."
    And I wait 1 second
    Then I should see "Text: content goes here ..." 2 times
