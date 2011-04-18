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

	@selenium @itsisu-todo
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

  @selenium @itsisu-todo
  Scenario: Offerings from the default class show learner data in the default class
    Given the following classes exist:
      | name          | teacher |
      | Default Class | teacher |
    And the class "Default Class" is the default class
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the following external activity exists:
      | name        | user    |
      | My Activity | teacher |
    When I login with username: teacher password: teacher
    And I am on the class page for "Default Class"
    And I drag the external activity "My Activity" to "#clazz_offerings"
    And I wait "2" seconds
    Then the external activity offering "My Activity" in the class "Default Class" should be a default offering
    When I am on the class page for "My Class"
    And I drag the external activity "My Activity" to "#clazz_offerings"
    And I wait "2" seconds
    Then the external activity offering "My Activity" in the class "My Class" should not be a default offering
    And the external activity named "My Activity" should have "offerings_count" equal to "2"
    When I login with username: student password: student
    And I am on the class page for "My Class"
    And I follow "run My Activity"
    And I login with username: teacher password: teacher
    And I am on the class page for "Default Class"
    Then I should see "My Activity"
    And I should see "joe user"
    And the learner count for the external activity "My Activity" in the class "Default Class" should be "1"

  @dialog
  @selenium @itsisu-todo
  Scenario: Runnables with offerings in regular classes can not be assigned to the default class
    Given the following classes exist:
      | name          | teacher |
      | Default Class | teacher |
    And the class "Default Class" is the default class
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the following external activity exists:
      | name        | user    |
      | My Activity | teacher |
    When I login with username: teacher password: teacher
    And I am on the class page for "My Class"
    And I drag the external activity "My Activity" to "#clazz_offerings"
    And I wait "2" seconds
    Then the external activity offering "My Activity" in the class "My Class" should not be a default offering
    And the external activity named "My Activity" should have "offerings_count" equal to "1"
    When I am on the class page for "Default Class"
    And I drag the external activity "My Activity" to "#clazz_offerings"
    And I wait "2" seconds
    Then I should see "The External Activity My Activity is already assigned in a class."
    And the external activity named "My Activity" should have "offerings_count" equal to "1"
    And the class "Default Class" should not have any offerings
