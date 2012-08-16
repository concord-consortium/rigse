Feature: Student runs a jnlps
  In order to use a super cool Java activity
  As a student
  I want to run a jnlp

  Background:
    Given The default project and jnlp resources exist using factories
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following simple investigations exist:
      | name                | user      | publication_status |
      | Test Investigation  | teacher   | published          |
    And the student "student" belongs to class "My Class"
    And the investigation "Test Investigation" is assigned to the class "My Class"
    And I login with username: student

  Scenario: Student runs jnlp
    When I follow "run Test Investigation"
    Then a jnlp file is downloaded
    And the jnlp file has a configuration for the student and offering

  Scenario: Student jnlps are not cached
    When I follow "run Test Investigation"
    Then the jnlp should not be cached

  Scenario: Student runs the same jnlp a second time
    When I follow "run Test Investigation"
    And a jnlp file is downloaded
    Then the jnlp file has a configuration for the student and offering
    And I simulate opening the jnlp a second time
    Then I should see an error message in the Java application

