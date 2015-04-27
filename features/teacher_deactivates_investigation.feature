Feature: Teacher can deactivate investigations from a class
  So my class can move on to other things
  As a teacher
  I want to unassign investigations from a class

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And a student has performed work on the investigation "Aerodynamics" for the class "My Class"
    And I am logged in with the username teacher

  Scenario: Teacher can see if student has performed work on an investigation
    When I am on the class page for "My Class"
    And I open the accordion for the offering for investigation "Aerodynamics" for the class "My Class"
    Then I should see "1 student response"

    When I follow "deactivate" on the investigation "Aerodynamics" from the class "My Class"
    And I am on the class page for "My Class"
    Then I should see "1 student response"

    When I follow "activate" on the investigation "Aerodynamics" from the class "My Class"
    And I am on the class page for "My Class"
    Then I should see "1 student response"
