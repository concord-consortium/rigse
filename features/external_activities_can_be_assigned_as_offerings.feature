Feature: External Activities can be assigned as offerings

  As a teacher
  I want to assign an External Activity as an offering in a class

  Background:
    Given The default project and jnlp resources exist using factories

  Scenario: External Offerings and Investigations are both assignable
    Given the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the following investigation exists:
      | name               | user    |
      | Test Investigation | teacher |
    And the following external activity exists:
      | name        | user    |
      | My Activity | teacher |
    When I assign the external activity "My Activity" to the class "My Class"
    Then the external activity named "My Activity" should have "offerings_count" equal to "1"
    When I assign the investigation "Test Investigation" to the class "My Class"
    Then the investigation named "Test Investigation" should have "offerings_count" equal to "1"
