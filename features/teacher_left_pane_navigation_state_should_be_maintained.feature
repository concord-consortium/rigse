Feature: Class state should be saved

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password   | first_name | last_name  |
      | teacher  | teacher    | John       | Nash       |   
    And the following classes exist:
      | name       | teacher |
      | My Class   | teacher |
      | Physics    | teacher |
    And the classes "My Class" are in a school named "VJTI"
    And the classes "Physics" are in a school named "VJTI"
    And I login with username: teacher password: teacher 
    And I am on "Student Roster" page for "My Class"
  
  
  @javascript
  Scenario: Teacher's state in the left pane should be maintained when navigating across classes
    When I follow "Physics" within left panel for class navigation
    Then I should see "Class Name : Physics"
    And I should be on "Student Roster" page for "Physics" 

  @javascript
  Scenario: Teacher's state in the left pane should be maintained after visiting some other part of the application
    When I go to the Manage Class Page 
    And I follow "Physics" within left panel for class navigation
    Then I should see "Class Name : Physics"
    And I should be on "Student Roster" page for "Physics" 
  
  @javascript
  Scenario: Teacher's state in the left pane should be maintained across sessions
    When I log out
    And I login with username: teacher password: teacher
    And I follow "Physics" within left panel for class navigation
    Then I should see "Class Name : Physics"
    Then I should be on "Student Roster" page for "Physics" 