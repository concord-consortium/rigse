Feature: Teacher manages instructional materials of a class
  
  As a teacher
  I want to manage my instructional materials of a class
  In order to make my class more effective
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following classes exist:
      | name        | teacher | class_word | semester |
      | My Class    | teacher | my_classes | Fall     |
      | Physics     | teacher | physics    | Fall     |
      | Mathematics | teacher | math       | Fall     |
      | Chemistry   | teacher | chem       | Fall     |
    And the classes "My Class, Physics, Mathematics" are in a school named "Harvard School"
    
    And the following multiple choice questions exists:
      | prompt | answers | correct_answer |
      | a      | a,b,c,d | a              |
      | b      | a,b,c,d | a              |
      | c      | a,b,c,d | a              |
      | d      | a,b,c,d | a              |
      | e      | a,b,c,d | a              |
      | f      | a,b,c,d | a              |
    And there is an image question with the prompt "image_q"
    And the following investigations with multiple choices exist:
      | investigation        | activity       | section   | page   | multiple_choices | image_questions | user      | activity_teacher_only |
      | Radioactivity        | Radio activity | section a | page 1 | a                | image_q         | teacher   | false                 |
      | Plant reproduction   | Plant activity | section b | page 2 | b                | image_q         | teacher   | false                 |
      | Aerodynamics         | Air activity   | section c | page 3 | c                | image_q         | teacher   | false                 |
      | Electricity          | Electrons      | section d | page 4 | d                | image_q         | teacher   | false                 |
      | Aerodynamics         | Aeroplane      | section e | page 5 | e                | image_q         | teacher   | true                  |
    And the following activities for the above investigations exist:
      | name                 | investigation | user    | publication_status | description                       |
      | Atmosphere           | Aerodynamics  | author  | published          | Atmosphere is a great material    |
    And the following activities with multiple choices exist:
      | activity | section   | page   | multiple_choices | image_questions | user      | activity_teacher_only |
      | Algebra  | section a | page 6 | f                | image_q         | teacher   | false                 |
    And the following assignments exist:
      | type          | name                 | class       |
      | investigation | Aerodynamics         | My Class    |
      | investigation | Plant reproduction   | My Class    |
      | investigation | Radioactivity        | My Class    |
      | investigation | Electricity          | Physics     |
      | investigation | Plant reproduction   | Physics     |
      | activity      | Algebra              | Physics     |
      | investigation | Aerodynamics         | Physics     |
    And the following offerings exist in the classes:
      | name                       | class       |
      | Lumped circuit abstraction | Mathematics |
      | Static discipline          | Mathematics |
    And the student "dave" belongs to class "My Class"
    And the student "chuck" belongs to class "My Class"
    And the student "taylor" belongs to class "My Class"
    And the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | dave      | My Class      | Radioactivity       | a               | a      |
      | dave      | My Class      | Radioactivity       | image_q         | Y      |
    And the following student answers:
      | student   | class         | activity            | question_prompt | answer |
      | taylor    | My Class      | Algebra             | f               | y      |
    And I am logged in with the username teacher
    And I go to Instructional Materials page for "My Class"
    
  @javascript
  Scenario: Teacher can follow link to Instructional Materials on their Class Page
    Then I should be on Instructional Materials page for "My Class"
    
  Scenario: Anonymous user can not view instructional materials of a class
    When I log out
    And I try to go to Instructional Materials page for "My Class"
    Then I should be on "my home page"
    
  Scenario: Teacher can click button to Manage Materials
    When I follow "Manage Materials"
    Then I should be on the class edit page for "My Class"
    
  Scenario: Teacher can click button to Add new materials
    When I follow "Assign Materials"
    Then I should be on the search instructional materials page
    
  Scenario: Teacher should see investigation tabs with the first tab selected
    Then I should see "Radioactivity" within the tab block for Instructional Materials
    And I should see "Plant reproduction" within the tab block for Instructional Materials
    And I should see "Aerodynamics" within the tab block for Instructional Materials
    And I should see "Investigation: Radioactivity"
    
  @javascript
  Scenario: Teacher should see activity name in tab
    Then I should see "Algebra" within the tab block for Instructional Materials
    
  @javascript
  Scenario: Teacher should be able to switch tabs
    When I click the tab of Instructional Materials with text "Plant reproduction"
    Then I should see "Investigation: Plant reproduction"
    
  @javascript
  Scenario: Teacher should be able to hide activities and their "Run Activity" buttons 
    When I follow "Hide Activities"
    Then I should see "Show Activities"
    
  @javascript
  Scenario: Teacher should be able to run the report
    When I click the tab of Instructional Materials with text "Radioactivity"
    And I follow "Run Report"
    Then A report window opens of offering "Radioactivity"
    
  Scenario: Teacher should be able to see all students assigned to the class
    Then I should see "Doe, Dave"
    And I should see "Smith, Chuck"
    
  @javascript
  Scenario: Teacher should be able to see student attempt progress bars
    When the following student answers:
      | student   | class         | investigation            | question_prompt | answer |
      | dave      | My Class      | Plant reproduction       | b               | a      |
      | dave      | My Class      | Plant reproduction       | image_q         | Y      |
    And I am on Instructional Materials page for "My Class"
    And I click the tab of Instructional Materials with text "Plant reproduction"
    Then I should see progress bars for the students
    
  Scenario: Teacher should see a message if no materials are assigned to this class.
    When I go to Instructional Materials page for "Chemistry"
    Then I should see "No materials assigned to this class."
    
  Scenario: Teacher should not get an error if no activities are present
    When I go to Instructional Materials page for "Mathematics"
    Then I should see "Investigation: Lumped circuit abstraction"
    
  Scenario: Teacher should see a message if no students are present
    When I go to Instructional Materials page for "Physics"
    Then I should see "No students have registered for this class yet"
    
  Scenario: Teacher should be able to run investigation as teacher
    When I follow "Run as Teacher" for the investigation "Aerodynamics"
    Then I receive a file for download with a filename like "_investigation_"
    
  Scenario: Teacher should be able to run investigation as student
    When I follow "Run as Student" for the investigation "Aerodynamics"
    Then I receive a file for download with a filename like "_investigation_"
    
  Scenario: Teacher should be able to run the activity
    When I follow "Run Activity" for the activity "Air activity"
    Then I receive a file for download with a filename like "_activity_"
    
  @javascript
  Scenario: Teacher should not see teacher only activity in the activity table
    When I go to Instructional Materials page for "My Class"
    And I click the tab of Instructional Materials with text "Aerodynamics"
    Then I should not see "Aeroplane" within the activity table
    
  @javascript
  Scenario: Teacher should see teacher only activity
    When I go to Instructional Materials page for "My Class"
    And I click the tab of Instructional Materials with text "Aerodynamics"
    Then I should see "Aeroplane (teacher only)"
    
  @javascript
  Scenario: Teacher should see a message if activity has not been attempted by any student
    And I follow "Air activity"
    Then I should see "Reporting is unavailable until at least one student has started this activity" within the lightbox in focus
    
  @javascript
  Scenario: Teacher should see a message if student has not attempted any activity
    And I follow "Doe, Dave"
    Then I should see "Reporting is unavailable until at least one activity is started by this student" within the lightbox in focus
    
  @javascript
  Scenario: Teacher should see a message if student has not attempted corresponding activity
    And I click progress bar on the instructional materials page for the student "dave" and activity "Air activity"
    Then I should see "Reporting is unavailable until the selected activity is started by this student" within the lightbox in focus
    