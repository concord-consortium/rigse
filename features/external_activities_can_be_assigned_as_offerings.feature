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
    And the following investigation exists:
      | name               | user    |
      | Test Investigation | teacher |
    And the investigation "Test Investigation" is published
    And the following external activity exists:
      | name        | user    |
      | My Activity | teacher |

  Scenario: External Offerings and Investigations are both assignable
    When I assign the external activity "My Activity" to the class "My Class"
    Then the external activity named "My Activity" should have "offerings_count" equal to "1"
    When I assign the investigation "Test Investigation" to the class "My Class"
    Then the investigation named "Test Investigation" should have "offerings_count" equal to "1"

  @selenium
  Scenario: External Activities and Investigations are draggable items
    Given I login with username: teacher password: teacher
    When I am on the class page for "My Class"
    Then I should see "My Activity"
    And I should see "Test Investigation"
    When I drag the investigation "Test Investigation" to "#clazz_offerings"
    And I wait "2" seconds
    And I drag the external activity "My Activity" to "#clazz_offerings"
    And I wait "2" seconds
    Then the external activity named "My Activity" should have "offerings_count" equal to "1"
    And the investigation named "Test Investigation" should have "offerings_count" equal to "1"
