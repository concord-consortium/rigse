Feature: Investigations show drafts

  As a teacher
  In order to tell which investigations can be assigned
  I want to see which investigations are drafts

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And I login with username: teacher password: teacher

  @selenium
  Scenario: The investigations list offering count shows on all pages
    Given the following investigations exist:
      | name            | user    | offerings_count | created_at                     | publication_status |
      | Investigation1  | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | published          |
      | Investigation2  | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation3  | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation4  | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | draft              |
      | Investigation5  | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation6  | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation7  | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | draft              |
      | Investigation8  | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation9  | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation10 | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | draft              |
      | Investigation11 | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | draft              |
      | Investigation12 | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | draft              |
      | Investigation13 | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | draft              |
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
    Then the checkbox for "drafts too:" should not be checked
    And I should see "Investigation1"
    But I should not see "Investigation2"
    When I check "drafts too:"
    And I wait for all pending requests to complete
    Then I should see "Previous"
    And I should see "Next"
    And I should see "Investigation1"
    And I should see "Investigation2"
    And I should see "Investigation3"
    When I follow "Next"
    Then I should see "Investigation21"
    And I should see "Investigation22"
    And I should see "Investigation23"
    And I should see "Investigation24"
    And the checkbox for "drafts too:" should be checked
    When I uncheck "drafts too:"
    Then I should not see "Investigation21"
