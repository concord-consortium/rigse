Feature: External Activities can be assigned as offerings

  As a teacher
  I want to assign an External Activity as an offering in a class

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded

  # DO NOT TOUCH THE BROWSER WINDOW THAT SELENIUM IS DRIVING
  # IT WILL CAUSE THE TEST TO FAIL
  @javascript
  Scenario: External Activities and Investigations are assigned
    Given I am logged in with the username teacher
    And I am on the class page for "My Class"
    When I assign the investigation "Mechanics" to the class "My Class"
    And I assign the external activity "My Activity" to the class "My Class"
    Then I should see "Mechanics" within "#clazz_offerings"
    And I should see "My Activity" within "#clazz_offerings"

  Scenario: Offering counts increase when either a external activity or investigation is assigned
    Given the external activity "My Activity" is assigned to the class "My Class"
    And the investigation "Mechanics" is assigned to the class "My Class"
    Then the external activity named "My Activity" should have "offerings_count" equal to "1"
    And the investigation named "Mechanics" should have "offerings_count" equal to "1"

