Feature: Student can not see deactivated offerings
  In order to only work on active offerings
  As a student
  I do not want to see deactivated offerings

  Background:
    Given The default project and jnlp resources exist using factories
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following simple investigations exist:
      | name                | user      | publication_status |
      | Test Investigation  | teacher   | published          |
    And the following resource pages exist:
      | name          | user      | publication_status |
      | Test Resource | teacher   | published          |
    And I am logged in with the username teacher
    And the student "student" belongs to class "My Class"
    And the investigation "Test Investigation" is assigned to the class "My Class"
    And the resource page "Test Resource" is assigned to the class "My Class"

  Scenario: Student should see activated offerings
    When I log out
    And I login with username: student
    Then I should see the run link for "Test Investigation"
    Then I should see the run link for "Test Resource"

  Scenario: Student should not see deactivated offerings
    When I am on the class page for "My Class"
    And I follow "Deactivate" on the investigation "Test Investigation" from the class "My Class"
    And I follow "Deactivate" on the resource page "Test Resource" from the class "My Class"
    And I log out
    And I login with username: student
    Then I should be on the homepage
    Then I should not see the run link for "Test Investigation"
    Then I should not see the run link for "Test Resource"
    And I should see "No offerings available." in the content

    When I am on the class page for "My Class"
    Then I should not see the run link for "Test Investigation"
    Then I should not see the run link for "Test Resource"
    And I should not see "View Test Resource" in the content

