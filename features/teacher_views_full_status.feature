Feature: Teacher can see full status
  
  As a teacher
  I should see the full status of students
  In order to make my class more effective
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login     | password | first_name   | last_name |
      | teacher   | teacher  | John         | Nash      |
      | peterson  | teacher  | peterson     | gaurav    |
    And the following classes exist:
      | name        | teacher  |
      | My Class    | teacher  |
      | Physics     | peterson |
    And the following multiple choice questions exists:
      | prompt | answers | correct_answer |
      | a      | a,b,c,d | a              |
      | b      | a,b,c,d | a              |
      | c      | a,b,c,d | a              |
      | d      | a,b,c,d | a              |
      | e      | a,b,c,d | a              |
    And there is an image question with the prompt "image_q"
    And the following investigations with multiple choices exist:
      | investigation        | activity       | section   | page   | multiple_choices | image_questions | user      | activity_teacher_only |
      | Radioactivity        | Radio activity | section a | page 1 | a                | image_q         | teacher   | false                 |
      | Radioactivity        | Nuclear Energy | section a | page 1 | a                | image_q         | teacher   | false                 |
      | Plant reproduction   | Plant activity | section b | page 2 | b                | image_q         | teacher   | false                 |
      | Radioactivity        | Aeroplane      | section d | page 4 | d                | image_q         | teacher   | true                  |
    And the following activities with multiple choices exist:
      | activity | section   | page   | multiple_choices | image_questions | user      |
      | Algebra  | section a | page 1 | a                | image_q         | teacher   |
    And the following assignments exist:
      | type          | name                 | class       |
      | investigation | Radioactivity        | My Class    |
      | investigation | Plant reproduction   | My Class    |
      | activity      | Algebra              | My Class    |
    And the following students exist:
      | login     | password  | first_name | last_name |
      | dave      | student   | Dave       | Doe       |
      | chuck     | student   | Chuck      | Smith     |
      | Mache     | student   | Mache      | Smith     |
    And the student "dave" belongs to class "My Class"
    And the student "chuck" belongs to class "My Class"
    And the student "Mache" belongs to class "Physics"
    And the following student answers:
      | student   | class    | investigation      | question_prompt | answer |
      | dave      | My Class | Radioactivity      | a               | y      |
      | chuck     | My Class | Plant reproduction | b               | Y      |
    And the following student answers:
      | student   | class    | activity            | question_prompt | answer |
      | Chuck     | My Class | Algebra             | a               | y      |
    And I login with username: teacher password: teacher
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
    And I login with username: teacher password: teacher
    And I am on the full status page for "My Class"
    Then the column for "Radioactivity" on the Full Status page should be expanded
    
    
  Scenario: Anonymous user cannot see the full status page
    When I am an anonymous user
    And I go to the full status page for "My Class"
    Then I should be on "my home page"
    
    
  Scenario: Teacher can see a message if no materials are in the class
    When I login with username: peterson password: teacher
    And I am on the full status page for "Physics"
    Then I should see "No materials assigned to this class."
    
    