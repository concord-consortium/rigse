Feature: Student can not see deactivated offerings
  In order to only work on active offerings
  As a student
  I do not want to see deactivated offerings

  Background:
    Given The default settings and jnlp resources exist using factories
    And I am logged in with the username teacher
    And the student "monty" belongs to class "class_with_no_students"

  Scenario: Student should see activated offerings
    When I log out
    And I login with username: monty
    Then I should see "Plant reproduction" in the content

  Scenario: Student should not see deactivated offerings
    When I am on the class page for "class_with_no_students"
    And I follow "Deactivate" on the external activity "Plant reproduction" from the class "class_with_no_students"
    And I log out
    And I login with username: monty
    Then I should be on my classes page
    And I should not see "run Plant reproduction" in the content
    And I should see "No offerings available." in the content

    When I am on the class page for "class_with_no_students"
    And I should not see "run Plant reproduction" in the content
    And I should see "No offerings available." in the content

