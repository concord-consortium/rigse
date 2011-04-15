Feature: Investigations can be duplicated

  As an author
  I want to dupliate investigations

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    And the following investigations exist:
      | name   | user   | offerings_count | created_at                     | publication_status |
      | Newest | author | 5               | Wed Jan 26 12:00:00 -0500 2011 | published          |
      | Medium | author | 10              | Wed Jan 23 12:00:00 -0500 2011 | published          |
      | Oldest | author | 20              | Wed Jan 20 12:00:00 -0500 2011 | published          |
    And I login with username: author password: author

  @javascript
  Scenario: Duplicating investigations have an offering count of 0
    Given I am on the investigations page for "Newest"
    When I duplicate the investigation
    Then the investigation "copy of Newest" should have been created
    And the investigation "copy of Newest" should have an offerings count of 0
