Feature: Teacher can see full status
  
  As a teacher
  I should see the full status of students
  In order to make my class more effective
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following student answers:
      | student   | class    | investigation      | question_prompt | answer |
      | dave      | My Class | Radioactivity      | a               | y      |
      | chuck     | My Class | Plant reproduction | b               | Y      |
    And the following student answers:
      | student   | class    | activity            | question_prompt | answer |
      | Chuck     | My Class | Algebra             | a               | y      |
    And I login with username: teacher password: password
    And I am on the full status page for "My Class"
    
  @javascript
  Scenario: Teacher can see all the offerings of the class
    Then I should see "Radioactivity"
    And I should see "Plant reproduction"
    And I should see "Algebra"
    
    
  Scenario: Teacher can see all the students assigned to the class
    Then I should see "Doe, Dave"
    And I should see "Smith, Chuck"
    
    
  Scenario: Teacher can see all the activities when an offering is expanded except teacher only activity
    When I expand the column "Radioactivity" on the Full Status page
    And I should wait 5 seconds
    Then the column for "Radioactivity" on the Full Status page should be expanded
    And I should see "Radio activity"
    And I should see "Nuclear Energy"
    And I should not see "Aeroplane"
    
    
  @javascript
  Scenario: Offering collapsed state is maintained across different parts of the application
    When I expand the column "Radioactivity" on the Full Status page
    And I should wait 5 seconds
    And the column for "Radioactivity" on the Full Status page should be expanded
    And I should see "Radio activity"
    And I should see "Nuclear Energy"
    And I go to the class edit page for "My Class"
    And I am on the full status page for "My Class"
    Then the column for "Radioactivity" on the Full Status page should be expanded
    
    
  @javascript
  Scenario: Offering collapsed state is maintained across sessions
    When I expand the column "Radioactivity" on the Full Status page
    And I should wait 5 seconds
    And the column for "Radioactivity" on the Full Status page should be expanded
    And I should see "Radio activity"
    And I should see "Nuclear Energy"
    And I log out
    And I login with username: teacher password: password
    And I am on the full status page for "My Class"
    Then the column for "Radioactivity" on the Full Status page should be expanded
    
    
  Scenario: Anonymous user cannot see the full status page
    When I am an anonymous user
    And I try to go to the full status page for "My Class"
    Then I should be on "my home page"
    
    
  Scenario: Teacher can see a message if no materials are in the class
    When I login with username: peterson password: password
    And I am on the full status page for "Physics"
    Then I should see "No materials assigned to this class."
    
    