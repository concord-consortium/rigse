Feature: Teacher can assign an offering to a class
  So my class can perform a task
  As a teacher
  I want to assign offerings to a class

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |

  Scenario: Teacher can assign an investigation to a class
    Given the following investigation exists:
      | name               | user    |
      | Test Investigation | teacher |
    When I assign the investigation "Test Investigation" to the class "My Class"
    Then the investigation named "Test Investigation" should have "offerings_count" equal to "1"

  Scenario: Teacher can assign a resource page to a class
    Given the following resource pages exist:
      | name               | user    |
      | Test Resource Page | teacher |
    When I assign the resource page "Test Resource Page" to the class "My Class"
    Then the resource page named "Test Resource Page" should have "offerings_count" equal to "1"

  Scenario: Teacher can assign an Activity to a class
    Given the following activities exist:
      | name          | user    |
      | Test Activity | teacher |
    When I assign the activity "Test Activity" to the class "My Class"
    Then the activity named "Test Activity" should have "offerings_count" equal to "1"

	@selenium
	Scenario: All potential offerings are visible
    Given the following investigation exists:
      | name               | user    |
      | Test Investigation | teacher |
		And the investigation "Test Investigation" is published
    And the following resource pages exist:
      | name               | user    |
      | Test Resource Page | teacher |
    And the following external activity exists:
      | name        | user    |
      | My Activity | teacher |
    And I login with username: teacher password: teacher
    And I am on the class page for "My Class"
		Then I should see "Investigation: Test Investigation"
		Then I should see "Resource Page: Test Resource Page"
		Then I should see "External Activity: My Activity"
