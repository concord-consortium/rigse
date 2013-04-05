Feature: Teacher can deactivate investigations from a class
  So my class can move on to other things
  As a teacher
  I want to unassign investigations from a class

  Background:
    Given The default project and jnlp resources exist using factories
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

  @dialog
  @javascript
  Scenario: Teacher drags active investigation with students off of class
    When I am on the class page for "My Class"
    And I drag the investigation "Aerodynamics" in the class "My Class" to "#offering_list"
    Then I need to confirm "Cannot delete offering with student data. Please deactivate instead."
    And I should see "Aerodynamics" within "#clazz_offerings"
    And the investigation "Aerodynamics" in the class "My Class" should be active
