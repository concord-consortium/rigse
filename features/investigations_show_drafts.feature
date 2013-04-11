Feature: Investigations show drafts

  As a teacher
  In order to tell which investigations can be assigned
  I want to see which investigations are drafts

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    Given I am logged in with the username teacher

  @javascript
  Scenario: The investigations list offering count shows on all pages
    Given the following empty investigations exist:
      | name            | user    | offerings_count | created_at                     | publication_status |
      | Investigation01 | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | published          |
      | Investigation02 | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation03 | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation04 | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | draft              |
      | Investigation05 | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation06 | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation14 | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation15 | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation16 | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | draft              |
      | Investigation17 | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation18 | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation19 | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | draft              |
      | Investigation20 | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation21 | teacher | 11              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation22 | teacher | 6               | Wed Jan 26 12:00:00 -0500 2011 | draft              |
      | Investigation23 | teacher | 22              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation24 | teacher | 33              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
    When I am on the investigations page
    Then the "drafts too:" checkbox should not be checked
    And I should see "Investigation01"
    But I should not see "Investigation02"
    When I check "drafts too:"
    And I wait for all pending requests to complete
    Then I should see "Previous"
    And I should see "Next"
    And I should see "Investigation01"
    And I should see "Investigation02"
    When I follow "Next"
    Then I should see "Investigation03"
    And I should see "Investigation21"
    And I should see "Investigation22"
    And I should see "Investigation23"
    And I should see "Investigation24"
    When I follow "Next"
    And the "drafts too:" checkbox should be checked
    When I uncheck "drafts too:"
    Then I should not see "WithLinksInv"
