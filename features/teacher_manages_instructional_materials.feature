Feature: Teacher manages instructional materials of a class
  
  As a teacher
  I want to manage my instructional materials of a class
  In order to make my class more effective
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         | Nash      |
    And the teachers "teacher" are in a school named "Harvard School"
    
    And the following semesters exist:
      | name     |
      | Fall     |
      | Spring   |
      
    And the following classes exist:
      | name        | teacher | class_word | semester |
      | My Class    | teacher | my_class   | Fall     |
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
    And there is an image question with the prompt "image_q"
    
    And the following investigations with multiple choices exist:
      | investigation        | activity       | section   | page   | multiple_choices | image_questions | user      |
      | Radioactivity        | Radio activity | section a | page 1 | a                | image_q         | teacher   |
      | Plant reproduction   | Plant activity | section b | page 2 | b                | image_q         | teacher   |
      | Aerodynamics         | Air activity   | section c | page 3 | c                | image_q         | teacher   |
      
    And the following assignments exist:
      | type          | name                 | class       |
      | investigation | Radioactivity        | My Class    |
      | investigation | Plant reproduction   | My Class    |
      | investigation | Aerodynamics         | My Class    |
      | investigation | Radioactivity        | Physics     |
      | investigation | Plant reproduction   | Physics     |
      | investigation | Aerodynamics         | Physics     |
      
    And the following offerings exist in the classes:
      | name                       | class       |
      | Lumped circuit abstraction | Mathematics |
      | Static discipline          | Mathematics |
      
    And the following students exist:
      | login     | password  | first_name | last_name |
      | dave      | student   | Dave       | Doe       |
      | chuck     | student   | Chuck      | Smith     |
    And the student "dave" belongs to class "My Class"
    And the student "chuck" belongs to class "My Class"
    
    And the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | dave      | My Class      | Radioactivity       | a               | a      |
      | dave      | My Class      | Radioactivity       | image_q         | Y      |
      
    And I am logged in with the username teacher
    And I go to Instructional Materials page for "My Class"
    
    
    
  @javascript
  Scenario: Teacher can follow link to Instructional Materials on their Class Page
    Then I should be on Instructional Materials page for "My Class"
    
    
  @javascript
  Scenario: Anonymous user can not view instructional materials of a class
    When I log out
    And I go to Instructional Materials page for "My Class"
    Then I should be on "my home page"
    
    
  @javascript
  Scenario: Teacher can click button to Manage Materials
    When I follow "Manage Materials"
    Then I should be on "the class edit page for "My Class""
    
    
  @javascript
  Scenario: Teacher can click button to Add new materials
    When I follow "Add new Materials to this class"
    Then I should be on the class page for "My Class"
    
    
  @javascript
  Scenario: Teacher should see investigation tabs with the first tab selected
    Then I should see "Radioactivity" within the tab block for Instructional Materials
    And I should see "Plant reproduction" within the tab block for Instructional Materials
    And I should see "Aerodynamics" within the tab block for Instructional Materials
    And I should see "Investigation: Radioactivity"
    
    
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
    When I follow "Run Report"
    Then A report window opens of offering "Radioactivity"
    
    
  @javascript
  Scenario: Teacher should be able to see all students assigned to the class
    Then I should see "Doe, Dave"
    And I should see "Smith, Chuck"
    
    
  @javascript
  Scenario: Teacher should be able to see student attempt progress bars
    Then I should see progress bars for the students
    
    
  @javascript
  Scenario: Teacher should see a message if no offerings are present
    When I go to Instructional Materials page for "Chemistry"
    Then I should see "No offerings present"
    
    
  @javascript
  Scenario: Teacher should see a message if no activities are present
    When I go to Instructional Materials page for "Mathematics"
    Then I should see "No activities available in this investigation"
    And I should not see "Show Run Activity buttons"
    And I should not see "Hide Run Activity buttons"
    
    
  @javascript
  Scenario: Teacher should see a message if no students are present
    When I go to Instructional Materials page for "Physics"
    Then I should see "No students have registered for this class yet"
    
    
  Scenario: Teacher should be able to run the investigation
    When I follow "Run Investigation"
    Then I receive a file for download with a filename like "_investigation_"
    
    
  Scenario: Teacher should be able to run the activity
    When I follow "Run Activity"
    Then I receive a file for download with a filename like "_activity_"
    
    