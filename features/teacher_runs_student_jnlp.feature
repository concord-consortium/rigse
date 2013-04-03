Feature: Teacher runs student jnlps
  In order to see the work of an individual student
  As a teacher
  I want to run a students jnlp

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the student "student" belongs to class "Class_with_no_assignment"
    And the investigation "Aerodynamics" is assigned to the class "Class_with_no_assignment"
    And the student "student" has run the investigation "Aerodynamics" in the class "Class_with_no_assignment"
    And I login with username: teacher

  Scenario: Teacher runs student jnlp from Class Page
    When I run the student's investigation for "Class_with_no_assignment"
    Then a jnlp file is downloaded
    And the jnlp file for "Aerodynamics" has a read-only configuration for the student and offering
