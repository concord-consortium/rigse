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
  Scenario: Authors can filter their own published materials
    Given the following users exist:
      | login    | password | roles |
      | author_1 | secret   | author |
    And the following External Activity exist:
      | name                | long_description   | user     | is_official |
      | external_activity_1 | description 1      | author_1 | true        |
      | external_activity_2 | description 2      | author_1 | false       |
      | external_activity_3 | description 3      | author   | true        |
    And I reindex external activity
    When I am logged in with the username author_1
    And I am on the search instructional materials page
    And I search for my own materials
    And I check "official" under Authorship
    Then I should see "external_activity_1"
    And I should not see "external_activity_2"
    And I should not see "external_activity_3"
