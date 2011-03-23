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
      | name        | user    | url                |
      | My Activity | teacher | http://concord.org |
    And the following students exist:
      | login   | password |
      | student | student  |

  # Currently need to set the following setting for this to work
  # that shouldn't be necessary
  # :runnable_mime_type: run_external_html
  @selenium
  Scenario: External Activity offerings are runnable
    Given the student "student" belongs to class "My Class"
    And the external activity "My Activity" is assigned to the class "My Class"
    And I login with username: student password: student
    When I go to my home page
    And follow "My Activity"
    Then the location should be "http://www.concord.org/"
