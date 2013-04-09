Feature: Teacher navigates using left pane
  
  As a teacher
  I want to visit various pages using left pane
  In order to make navigation more effective
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I login with username: teacher
    
    
  Scenario: Teachers can see their class name
    Then I should see "My Class"
    
    
  Scenario: Teacher visits Student Roster page
    When I follow "My Class"
    And I follow "Student Roster"
    Then I should be on "Student Roster" page for "My Class"
    
    
  Scenario: Teacher visits Class Setup page
    When I follow "My Class"
    And I follow "Class Setup"
    Then I should be on the class edit page for "My Class"
    
    
  Scenario: Teacher visits Materials page
    When I follow "My Class"
    And I follow "Materials"
    Then I should be on Instructional Materials page for "My Class"
    
    
  Scenario: Teacher visits Full Status page
    When I follow "My Class"
    And I follow "Full Status"
    Then I should be on the full status page for "My Class"
    
    