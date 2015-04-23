Feature: Class state should be saved

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
  
  
  @javascript
  Scenario: Teacher should land on instructional materials page
    When I am on the home page
    When I follow "Physics" within left panel for class navigation
    Then I should be on the Instructional Materials page for "Physics"
    
    
  @javascript
  Scenario: Teacher's state in the left pane should be maintained when navigating across classes
    When I am on "Student Roster" page for "My Class"
    And I follow "Physics" within left panel for class navigation
    Then I should be on "Student Roster" page for "Physics" 

  @javascript
  Scenario: Teacher's state in the left pane should be maintained after visiting some other part of the application
    When I am on "Student Roster" page for "My Class"
    And I go to the Manage Class Page 
    And I follow "Physics" within left panel for class navigation
    Then I should see "Class Name : Physics"
    And I should be on "Student Roster" page for "Physics" 
  
  @javascript
  Scenario: Teacher's state in the left pane should be maintained across sessions
    When I am on "Student Roster" page for "My Class"
    And I log out
    And I login with username: teacher password: password
    And I follow "Physics" within left panel for class navigation
    Then I should see "Class Name : Physics"
    And I should be on "Student Roster" page for "Physics" 
