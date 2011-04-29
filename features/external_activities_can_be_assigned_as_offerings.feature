Feature: External Activities can be assigned as offerings

  As a teacher
  I want to assign an External Activity as an offering in a class

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the following simple investigations exist:
      | name               | user    |
      | Test Investigation | teacher |
    And the investigation "Test Investigation" is published
    And the following external activity exists:
      | name        | user    |
      | My Activity | teacher |

  # DO NOT TOUCH THE BROWSER WINDOW THAT SELENIUM IS DRIVING
  # IT WILL CAUSE THE TEST TO FAIL
  @selenium @itsisu-todo
  Scenario: External Activities and Investigations are assigned
    Given I login with username: teacher password: teacher
    And I am on the class page for "My Class"
    When I assign the investigation "Test Investigation"
    And I assign the external activity "My Activity"
    Then I should see "Test Investigation" within "#clazz_offerings"
    And I should see "My Activity" within "#clazz_offerings"

  Scenario: Offering counts increase when either a external activity or investigation is assigned
    Given the external activity "My Activity" is assigned to the class "My Class"
    And the investigation "Test Investigation" is assigned to the class "My Class"
    Then the external activity named "My Activity" should have "offerings_count" equal to "1"
    And the investigation named "Test Investigation" should have "offerings_count" equal to "1"

