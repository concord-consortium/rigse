Feature: Investigations show the offerings count
  So I can see how many times an investigation has been assigned
  As a teacher
  I want to see the offerings count

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And I login with username: teacher password: teacher

    @selenium
    Scenario: The investigations list can show the offerings count
      Given the following investigations exist:
        | name   | user    | offerings_count | created_at                     | publication_status |
        | Newest | teacher | 5               | Wed Jan 26 12:00:00 -0500 2011 | published          |
        | Medium | teacher | 10              | Wed Jan 23 12:00:00 -0500 2011 | published          |
        | Oldest | teacher | 20              | Wed Jan 20 12:00:00 -0500 2011 | published          |
      When I show offerings count on the investigations page
      Then I should see "assigned 5 times"
      And I should see "assigned 10 times"
      And I should see "assigned 20 times"
