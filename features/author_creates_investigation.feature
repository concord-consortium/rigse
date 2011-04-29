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
    Given the following web models exist:
      | name         | url         |
      | My Web Model | http://home |
    When I go to the create investigation page
    And I fill in the following:
      | investigation[name]        | Test Investigation    |
      | investigation[description] | testing testing 1 2 3 |
    And I save the investigation
    Then I should see "Investigation was successfully created."
    When I add a new activity to the investigation
    Then I should see "Activity Name"
    When I fill in the following:
      | activity[name]        | Test Activity              |
      | activity[description] | What is the current thing? |
    And I press "Save"
    Then I should see "Activity was successfully updated"
    When I add a new section to the activity
    And I add a new page to the section
    And I add a "Multiple Choice Question" to the page
    Then I should see "Multiple Choice Question: Why do you think"
    When I add a "Open Response" to the page
    Then I should see "Open Response: You can use HTML content"
    When I add a "Web Model" to the page
    Then I should see "Web Model: My Web Model"
