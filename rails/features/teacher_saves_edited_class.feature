Feature: Teacher edits and saves class information

  As a teacher
  I want to edit my classes
  In order to keep my classes updated

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And the classes "Mathematics" are in a school named "VJTI"
    And I am logged in with the username teacher
    And I am on "the class edit page for "Mathematics""

  @javascript
  Scenario: Teacher can see all the teachers which are in the class
    Then I should see "Taylor, P. (peterson)"
    And I should see "Nash, J. (teacher)"

  @javascript
  Scenario: Teacher can see all the teachers which are not in the class
    Then "Fernandez, A. (albert)" should be a teacher option

  @javascript
  Scenario: Teacher can add teacher from the class edit page
    When I select "Fernandez, A. (albert)" from "teacher_id_selector"
    And I press "Add"
    Then I should see "Fernandez, A. (albert)"

  @dialog
  @javascript
  Scenario: Teacher can remove teacher from the class edit page
    When I follow remove image for the teacher name "Taylor, P. (peterson)"
    And accept the dialog
    Then I should not see the remove image for the teacher name "Taylor, P. (peterson)"

  @dialog
  @javascript
  Scenario: Teacher can remove themselves as teacher from the class edit page
    When I follow remove image for the teacher name "Nash, J. (teacher)"
    And accept the dialog
    Then I should not see the remove image for the teacher name "Nash, J. (teacher)"

  @javascript
  Scenario: Teacher saves class setup information
    When I fill in Class Name with "Basic Electronics"
    And I fill Description with "This is a biology class"
    And I fill Class Word with "BETRX"
    And I press "Save"
    Then I should be on Instructional Materials page for "Basic Electronics"
    And I should see "Class was successfully updated."

