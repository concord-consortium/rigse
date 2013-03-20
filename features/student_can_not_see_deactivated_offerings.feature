Feature: Student can not see deactivated offerings
  In order to only work on active offerings
  As a student
  I do not want to see deactivated offerings gg 

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    And the investigation "Plant reproduction" is assigned to the class "My Class"
    And the resource page "NewestResource" is assigned to the class "My Class"

  Scenario: Student should see activated offerings
    When I log out
    And I login with username: student
    Then I should see the run link for "Plant reproduction"
    Then I should see the run link for "NewestResource"

  Scenario: Student should not see deactivated offerings
    When I am on the class page for "My Class"
    And I follow "Deactivate" on the investigation "Plant reproduction" from the class "My Class"
    And I follow "Deactivate" on the resource page "NewestResource" from the class "My Class"
    And I log out
    And I login with username: student
    Then I should be on the homepage
    Then I should not see the run link for "Plant reproduction"
    Then I should not see the run link for "NewestResource"
    And I should see "No offerings available." in the content

    When I am on the class page for "My Class"
    Then I should not see the run link for "Plant reproduction"
    Then I should not see the run link for "NewestResource"
    And I should not see "View NewestResource" in the content

