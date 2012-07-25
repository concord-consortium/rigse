Feature: Teacher manages a mix instructional materials of a class

  As a teacher
  I want to manage my instructional materials of a class
  In order to make my class more effective

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         | Nash      |
    And the teachers "teacher" are in a school named "Harvard School"  
    And the following students exist:
       | login     | password  | first_name | last_name |
       | student   | password  | Student    | Doe       |
    And the mixed runnable types class
    And I am logged in with the username teacher

  Scenario: Teacher can view materials page for class with multiple runnable types
    When I go to the Instructional Materials page for "Mixed Runnable Types"
    Then I should see "Sample"

  @javascript
  Scenario: Teacher can run a report for each material
    When I go to the Instructional Materials page for "Mixed Runnable Types"
	Then each material has a report link