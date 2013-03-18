Feature: External Activities can be run as offerings

  As a student
  I want to run an External Activity that has been assigned to me

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following external activity exists:
      | name        | user    | url               |
      | My Activity | teacher | /mock_html/test-external-activity.html |

  Scenario: External Activity offerings are runnable
    When the external activity "My Activity" is assigned to the class "My Class"
    And I am logged in with the username student
    When I go to my home page
    And run the external activity
    Then I should be on /mock_html/test-external-activity.html
