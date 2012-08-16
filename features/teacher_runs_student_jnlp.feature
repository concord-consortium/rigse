Feature: Teacher runs student jnlps
  In order to see the work of an individual student
  As a teacher
  I want to run a students jnlp

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
    And the student "student" has run the investigation "Test Investigation" in the class "My Class"
    And I login with username: teacher

  Scenario: Teacher runs student jnlp from Class Page
    When I run the student's investigation
    Then a jnlp file is downloaded
    And the jnlp file has a read-only configuration for the student and offering
