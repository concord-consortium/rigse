Feature: Teacher views report

  In order to know how students have done on an offering
  As a teacher
  I want to see a report of their work

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    
  Scenario: A teacher views a report of an investigation
    Given the following investigations with multiple choices exist:
        | investigation        | activity | section   | page   | multiple_choices | image_questions | user      |
        | first investigation  | act 3    | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type          | name                 | class            |
        | investigation | first investigation  | Class_with_no_assignment    |
    And the following student answers:
        | student   | class         		   | investigation       | question_prompt | answer |
        | student   | Class_with_no_assignment | first investigation | a               | a      |
        | student   | Class_with_no_assignment | first investigation | image_q         | Y      |
        | dave      | Class_with_no_assignment | first investigation | a               | b      |
    When I am logged in with the username teacher
    And go to the class page for "Class_with_no_assignment"
    And I should see "Report" within ".action_menu_activity"

  # Report is now handled by an external service.
  # see spec/api/v1/reports_controller_spec.rb to test the related API.
