Feature: Teacher can assign an offering to a class
  So my class can perform a task
  As a teacher
  I want to assign offerings to a class

  Background:
    Given The default project and jnlp resources exist using factories

  @selenium
  Scenario: Teacher can assign an investigation to a class
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following investigation exists:
      | name                | user      |
      | Test Investigation  | teacher   |
    When I assign the investigation "Test Investigation" to the class "My Class"
    Then the investigation named "Test Investigation" should have "offerings_count" equal to "1"

  @selenium
  Scenario: Teacher can assign a resource page to a class
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following resource pages exist:
      | name                | user      |
      | Test Resource Page  | teacher   |
    When I assign the resource page "Test Resource Page" to the class "My Class"
    Then the resource page named "Test Resource Page" should have "offerings_count" equal to "1"
