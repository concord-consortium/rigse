Feature: External Activities can be run as offerings

  As a student
  I want to run an External Activity that has been assigned to me

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the following external activity exists:
      | name        | user    | url               |
      | My Activity | teacher | /home |
    And the following students exist:
      | login   | password |
      | student | student  |

  @javascript
  Scenario: External Activity offerings are runnable
    Given the student "student" belongs to class "My Class"
    And the external activity "My Activity" is assigned to the class "My Class"
    And I login with username: student password: student
    When I go to my home page
    And follow "My Activity"
    Then I should be on /home
