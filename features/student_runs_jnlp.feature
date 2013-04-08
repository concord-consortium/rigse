Feature: Student runs a jnlps
  In order to use a super cool Java activity
  As a student
  I want to run a jnlp

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I login with username: student
  
  Scenario: Student runs jnlp
    When I run the investigation
    Then a jnlp file is downloaded
    And the jnlp file for "Aerodynamics" has a configuration for the student and offering

  Scenario: Student jnlps are not cached
    When I run the investigation
    Then the jnlp should not be cached

  @pending
  Scenario: Student runs the same jnlp a second time
    When I run the investigation
    And a jnlp file is downloaded
    Then the jnlp file has a configuration for the student and offering
    And I simulate opening the jnlp a second time
    Then I should see an error message in the Java application

