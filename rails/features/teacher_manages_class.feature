Feature: Teacher manages a class

  As a teacher
  I want to manage my classes
  In order to make classes more effective

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    And I go to the Manage Class Page


  @javascript
  Scenario: Teacher creates a copy of a class
    When I follow copy class link for the class "Mathematics"
    And I fill in "Class Name:" with "Copy of Mathematics"
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    And I wait 1 seconds
    And I wait 1 seconds
    Then I should see "Copy of Mathematics"
    And "Copy of Mathematics" should be the last on the list with id "sortable"
    And "Copy of Mathematics" should be the last class within left panel for class navigation


  @javascript
  Scenario: Teacher should be on Manage their Class Page
    Then I should be on Manage Class Page


  @javascript
  Scenario: Anonymous user can not manage a class
    Given I am an anonymous user
    When I try to go to the Manage Class Page
    Then I should be on "the signin page"


  @javascript
  Scenario: Teacher can reorder the class list
    When I move "Mathematics" to the top of the list with id "sortable"
    And the Manage class list state starts saving
    And the modal for saving manage classes dissappears
    Then "Mathematics" should be the first on the list with id "sortable"
    And "Mathematics" should be the first class within left panel for class navigation


  @javascript
  Scenario: Teacher deactivates classes
    When I uncheck "Biology"
    And the Manage class list state starts saving
    And the modal for saving manage classes dissappears
    # this requires a reload to see the changes in the menu
    # the reloads should be removed from this test if this is fixed
    Then I should see "Biology" within left panel for class navigation
    And I reload the page
    Then I should not see "Biology" within left panel for class navigation
    When I uncheck "Geography"
    And I reload the page
    And I should not see "Geography" within left panel for class navigation


  @javascript
  Scenario: Student logs in and visits a class page which the teacher has deactivated
    When I uncheck "My Class"
    And the Manage class list state starts saving
    And the modal for saving manage classes dissappears
    And I log out
    And I login with username: student
    Then I should see "My Class"
    And I should see "Class_with_no_assignment"
    And I should see "Class_with_no_attempts"


  @javascript
  Scenario: Teacher logs in and visits a class page which some other teacher has deactivated
    Given the following teacher and class mapping exists:
      | class_name  | teacher                   |
      | Mathematics |  teacher_with_no_class    |
      | Biology     |  teacher_with_no_class    |
      | Geography   |  teacher_with_no_class    |
    When I uncheck "Biology"
    And the Manage class list state starts saving
    And the modal for saving manage classes dissappears
    And I uncheck "Geography"
    And the Manage class list state starts saving
    And the modal for saving manage classes dissappears
    And I log out
    And I login with username:  teacher_with_no_class
    Then I should see a class named "Mathematics" in the navigtion
    And I should see a class named "Biology" in the navigtion
    And I should see a class named "Geography" in the navigtion


  @javascript
  Scenario: Teacher creates a copy of a class to which another teacher belongs and the other teacher logs in.
    Given the following teacher and class mapping exists:
      | class_name  | teacher                   |
      | Mathematics     |  teacher_with_no_class    |
      | Chemistry   |  teacher_with_no_class    |
      | Mathematics |  teacher_with_no_class    |
    When I follow copy class link for the class "Mathematics"
    And I fill in "Class Name:" with "Copy of Mathematics"
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    And I wait 1 seconds
    And I log out
    And login with username:  teacher_with_no_class
    And I am on Manage Class Page
    Then I should see "Copy of Mathematics"


  @javascript
  Scenario: Teacher fills in class name with a blank string while creating copy of a class
    When I follow copy class link for the class "Mathematics"
    And I fill in "Class Name:" with ""
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    And I wait 1 seconds
    Then I should see "Name can't be blank"


  @javascript
  Scenario: Teacher fills in class word with a blank string while creating copy of a class
    When I follow copy class link for the class "Mathematics"
    And I fill in "Class Name:" with "Copy of Mathematics"
    And I fill in "Class Word:" with ""
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    And I wait 1 seconds
    Then I should see "Class word can't be blank"


  @javascript
  Scenario: Teacher fills in class word which has already been taken
    When I follow copy class link for the class "Mathematics"
    And I fill in "Class Name:" with "Copy of Mathematics"
    And I fill in "Class Word:" with "phy"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    And I wait 1 seconds
    Then I should see "Class word has already been taken"
