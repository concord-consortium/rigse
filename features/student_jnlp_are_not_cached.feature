Feature: Student offering jnlps are not cached
  In order to save student data correctly
  As a student
  I don't want a cached jnlp

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
    And I login with username: teacher password: teacher
    And the student "student" belongs to class "My Class"
    And the investigation "Test Investigation" is assigned to the class "My Class"

  Scenario: Student should see activated offerings
    When I log out
    And I login with username: student password: student
    And I follow "run Test Investigation"
    Then the jnlp should not be cached
