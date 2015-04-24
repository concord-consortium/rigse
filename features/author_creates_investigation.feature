Feature: An author creates an investigation
  As a Investigations author
  I want to create an investigation
  So that students can take it.

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded

  Scenario: The author creates an investigation
    Given a mock gse
    And I am logged in with the username author
    When I go to the create investigation page
    Then I should see "Sequence: (new)"
    When I fill in the following:
      | investigation[name]           | Test Investigation    |
      | investigation[description]    | testing testing 1 2 3 |
    And I save the investigation
    Then I should see "Sequence was successfully created."
