Feature: An author adds multiple choice questions
  As a Investigations author
  I want to add a multiple choice questions to my investigations
  So that I can understand what my students are learning.

  Background:
    Given The default project and jnlp resources exist using factories

  @javascript
  Scenario: The author adds a multiple choice question to an investigation
    Given the following simple investigations exist:
      | name              | description           | user   |
      | testing fast cars | how fast can cars go? | author |

    And I am logged in with the username author
    When I go to the first page of the "testing fast cars" investigation
    Then I should see "Page: testing fast cars"
    When I add a "Multiple Choice Question" to the page
    Then I should see "Why do you think ..."
    When I follow xpath "//a[@title='edit multiple choice question']"
    # this wait is necessary for IE please fixme
    And I wait 1 second
    Then I should see "choices"
    And I should see "Enable Rationale"
    And I should see "Multiple Selection"
    And I should see "a"
    And I should see "b"
    And I should see "c"

  @javascript
  Scenario: The author adds a multiple choice question to an investigation
    Given the following users exist:
      | login  | password | roles  |
      | author | author   | author |
    Given the following simple investigations exist:
      | name              | description           | user   |
      | testing fast cars | how fast can cars go? | author |

    And I am logged in with the username author
    When I go to the first page of the "testing fast cars" investigation
    Then I should see "Page: testing fast cars"
    When I add a "Multiple Choice Question" to the page
    Then I should see "Why do you think ..."
    When I follow xpath "//a[@title='edit multiple choice question']"
    # this wait is necessary for IE please fixme
    And I wait 1 second
    Then I should see "choices"
    And I should see "Enable Rationale"
    And I should see "Multiple Selection"
    And I should see "a"
    And I should see "b"
    And I should see "c"
    When I follow "delete" within "span.delete_link"
    And I press "Save"
    # this is necessary to make sure the Save ajax request has completed
    Then I should not see "choices"
    And I go to the first page of the "testing fast cars" investigation
    Then I should see "Why do you think ..."
    And I should see "b"
    And I should see "c"
    But I should not see the xpath "//a[@value='a']"
