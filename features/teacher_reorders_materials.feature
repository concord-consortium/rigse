Feature: Teacher reorders materials assigned to the class
  In order to present materials in a logical order to students
  the teacher
  should be able reorder them 

  Background:
    Given The default project and jnlp resources exist using factories
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the following teachers exist:
      | login    | password   | first_name | last_name  |
      | teacher  | teacher    | John       | Nash       |
      | albert   | teacher    | Albert     | Einstien   |
    And  the teachers "teacher , albert" are in a school named "VJTI"
  	And the following semesters exist:
      | name     | start_time          | end_time            |
      | Fall     | 2012-12-01 00:00:00 | 2012-03-01 23:59:59 |
      | Spring   | 2012-10-10 23:59:59 | 2013-03-31 23:59:59 |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the classes "My Class" are in a school named "VJTI"
    And the student "student" belongs to class "My Class"   

  @javascript
  Scenario: Teacher reorders materials and students sees them in the correct order
    Given the following offerings exist
       | name                      |
       | Lumped circuit abstraction|
       | static discipline         |
       | Non Linear Devices        |
    And I am logged in with the username teacher
    And I am on the class edit page for "My Class"
    And I move investigation named "Non Linear Devices" to the top of the list
    And I press "Save"
    When I login with username: student
    And I follow "My Class"
    And I should see "Lumped circuit abstraction"
    And I should see "Non Linear Devices"
    And I should see "static discipline"
    And the first investigation in the list should be "Non Linear Devices"

  @javascript
  Scenario: Teacher reorders materials with the default class feature enabled
    Given the default class is created
    And the following default class offerings exist
       | name                      |
       | Lumped circuit abstraction|
       | static discipline         |
       | Non Linear Devices        |
    And I am logged in with the username teacher
    When I am on the class page for "My Class"
    And I assign the investigation "Lumped circuit abstraction" to the class "My Class"
    And I assign the investigation "static discipline" to the class "My Class"
    And I assign the investigation "Non Linear Devices" to the class "My Class"
    And I am on the class edit page for "My Class"
    And I move investigation named "Non Linear Devices" to the top of the list
    And I press "Save"
    When I login with username: student
    And I follow "My Class"
    And I should see "Lumped circuit abstraction"
    And I should see "Non Linear Devices"
    And I should see "static discipline"
    And the first investigation in the list should be "Non Linear Devices"