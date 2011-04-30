Feature: An author creates an investigation
  As a Investigations author
  I want to create an investigation
  So that students can take it.

  Background:
    Given The default project and jnlp resources exist using factories
    And a mock gse
    And the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    And I login with username: author password: author

  Scenario: The author creates an investigation
    When I go to the create investigation page
    Then I should see "Investigation: (new)"
    When I fill in the following:
      | investigation[name]        | Test Investigation    |
      | investigation[description] | testing testing 1 2 3 |
    And I save the investigation
    Then I should see "Investigation was successfully created."

  @javascript
  Scenario: Author creates investigation with web models, open responses, and multiple choices
    When I go to the create investigation page
    And I fill in the following:
      | investigation[name]        | Test Investigation    |
      | investigation[description] | testing testing 1 2 3 |
    And I save the investigation
    Then I should see "Investigation was successfully created."
    When I add a "Web Model" to the page
    And I add a "Multiple Choice Question" to the page
    And I add a "Open Response" to the page
    Then I should see "Multiple Choice Question: Why do you think"
    And I should see "Open Response: You can use HTML content"
    And I should see "Web Model: My Web Model"
