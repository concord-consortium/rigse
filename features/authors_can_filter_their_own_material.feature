Feature: Author can filter their own material

  In order to find my own material
  As an author
  I need to create and filter material

  Background:
    Given the database has been seeded
    And I am logged in with the username author

  Scenario: Anonymous user cannot see authored by me
    When I log out
    And I go to the search instructional materials page
    Then I should not see "authored by me"

  Scenario: Anonymous user cannot see authored by me
    When I am on the search instructional materials page
    Then I should see "authored by me"

  @javascript @search
  Scenario: Authors can filter Interactive using authored by me
    Given the following users exist:
      | login    | password | roles  |
      | author_1 | secret   | author |
      | author_2 | secret   | author |
    And the following Interactive exist:
      | name          | description   | user     |
      | interactive_1 | description 1 | author_1 |
      | interactive_2 | description 2 | author_2 |
    And I reindex interactive
    When I am logged in with the username author_1
    And I am on the search instructional materials page
    And I check "Find only Materials authored by me"
    Then I should see "interactive_1"
    And I should not see "interactive_2"
    When I am logged in with the username author_2
    And I am on the search instructional materials page
    And I check "Find only Materials authored by me"
    Then I should see "interactive_2"
    And I should not see "interactive_1"


  @javascript @search
  Scenario: Authors can filter External Activity using authored by me
    Given the following users exist:
      | login    | password | roles |
      | author_1 | secret   | author |
    And the following External Activity exist:
      | name                | description   | user     | is_official |
      | external_activity_1 | description 1 | author_1 | true        |
      | external_activity_2 | description 2 | author_1 | false       |
    And I reindex external activity
    When I am logged in with the username author_1
    And I am on the search instructional materials page
    And I check "official" under Authorship
    Then I should see "external_activity_1"
    And I should not see "external_activity_2"
    When I uncheck "official" under Authorship
    And I check "contributed" under Authorship
    Then I should see "external_activity_2"
    And I should not see "external_activity_1"
    When I check "Find only Materials authored by me"
    Then I should see "external_activity_1"
    And I should see "external_activity_2"

  @javascript @search
  Scenario: Authors can filter their own published materials
    Given the following users exist:
      | login    | password | roles |
      | author_1 | secret   | author |
    And the following External Activity exist:
      | name                | description   | user     | is_official |
      | external_activity_1 | description 1 | author_1 | true        |
      | external_activity_2 | description 2 | author_1 | false       |
      | external_activity_3 | description 3 | author   | true        |
    And I reindex external activity
    When I am logged in with the username author_1
    And I am on the search instructional materials page
    And I check "Find only Materials authored by me"
    And I check "official" under Authorship
    Then I should see "external_activity_1"
    And I should not see "external_activity_2"
    And I should not see "external_activity_3"
