Feature: Teacher views report from the instructional materials page of a class

  As a teacher
  I want to see report from the instructional materials of a class
  In order to see the attempts of students.

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    And I go to Instructional Materials page for "My Class"


  @javascript
  Scenario: Teacher should be able to toggle names
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | c               | y      |
      | chuck     | My Class       | Aerodynamics        | a               | Y      |
    And I go to Instructional Materials page for "My Class"
    And I should see "report"

  # The actual report has been moved to an external service
  # We need to create tests for the API endpoint, and the materials we see there
  # see spec/api/v1/reports_controller_spec.rb