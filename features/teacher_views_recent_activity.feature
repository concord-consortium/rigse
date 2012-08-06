Feature: Teacher can see recent activity
  
  As a teacher
  I should see recent activities of students in all the classes
  In order to make my class more effective
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password | first_name | last_name |
      | teacher | teacher  | John       | Nash      |
      | albert  | albert   | Albert     | Fernandez |
      | robert  | robert   | Robert     | Fernandez |
    And the teachers "teacher" are in a school named "Harvard School"
    And the following semesters exist:
      | name   |
      | Fall   |
      | Spring |
    And the following classes exist:
      | name        | teacher | class_word | semester |
      | My Class    | teacher | my_class   | Fall     |
      | Physics     | teacher | physics    | Fall     |
      | Mathematics | teacher | math       | Fall     |
      | Chemistry   | teacher | chem       | Fall     |
      | Mechanics   | teacher | mech       | Fall     |
      | Biology     | albert  | biol       | Fall     |
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
      | investigation      | activity       | section   | page   | multiple_choices | image_questions | user      |
      | Radioactivity      | Radio activity | section a | page 1 | a                | image_q         | teacher   |
      | Plant reproduction | Plant activity | section b | page 2 | b                | image_q         | teacher   |
      | Aerodynamics       | Air activity   | section c | page 3 | c                | image_q         | teacher   |
    And the following assignments exist:
      | type          | name                 | class       |
      | investigation | Radioactivity        | My Class    |
      | investigation | Plant reproduction   | My Class    |
      | investigation | Radioactivity        | Physics     |
      | investigation | Plant reproduction   | Physics     |
      | investigation | Aerodynamics         | Physics     |
      | investigation | Aerodynamics         | Mechanics   |
    And the following offerings exist in the classes:
      | name                       | class       |
      | Lumped circuit abstraction | Mathematics |
      | Static discipline          | Mathematics |
    And the following students exist:
      | login | password | first_name | last_name |
      | dave  | student  | Dave       | Doe       |
      | chuck | student  | Chuck      | Smith     |
      | shon  | student  | shon       | done      |
      | ankur | student  | ankur      | gaurav    |
      | monty | student  | Monty      | Donald    |
    And the student "dave" belongs to class "My Class"
    And the student "chuck" belongs to class "Physics"
    And the student "chuck" belongs to class "Mechanics"
    And the student "shon" belongs to class "Physics"
    And the student "ankur" belongs to class "Physics"
    And I login with username: teacher password: teacher
    
    
  @javascript
  Scenario: Teacher should see a message if no investigation is assigned to the class
    When I login with username: albert password: albert
    And I follow "Recent Activity" within left panel for class navigation
    Then I should see "You need to assign investigations to your classes."
    And I should see "Once your students have started work this page will show you a dashboard of recent student progress."
    
    
  @javascript
  Scenario: Teacher should see a message if no activity is assigned to any investigation
    When the following empty investigations exist:
     | name      | user   | offerings_count | publication_status |
     | Digestion | albert | 5               | published          |
    And the following assignments exist:
     | type          | name      | class   |
     | investigation | Digestion | Biology |
    And the student "monty" belongs to class "Biology"
    And I login with username: albert password: albert
    Then I should see "Once your students have started work this page will show you a dashboard of recent student progress."
    
    
  @javascript
  Scenario: Teacher should see a message if no student is assigned to the class
    When the following empty investigations exist:
     | name      | user   | offerings_count | publication_status |
     | Digestion | albert | 5               | published          |
    And the following assignments exist:
     | type          | name      | class   |
     | investigation | Digestion | Biology |
    And I login with username: albert password: albert
    Then I should see "You have not yet assigned students to your classes."
    And I should see "Once your students have started work this page will show you a dashboard of recent student progress."
    
    
  @javascript
  Scenario: Teacher should view the progress bar for recent investigation
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | ankur     | Physics       | Aerodynamics        | c               | y      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    Then I should see the progress of the student within the first recent activity on the recent activity page
    
    
  @javascript
  Scenario: Teacher views the class at the top where most recent activity occurred
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | dave      | My Class      | Radioactivity       | a               | a      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    Then "Physics:[\s\r\n]+Aerodynamics" should appear before "My Class:[\s\r\n]+Radioactivity"
    
    
  @javascript
  Scenario: Teacher should view the students grouped by progress
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | ankur     | Physics       | Aerodynamics        | c               | y      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "gaurav, ankur" in In-progress on the recent activity page
    And I should see "Completed Smith, Chuck"
    And I should see "Not yet started done, shon"
    
    
  @javascript
  Scenario: Teacher views class size
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | ankur     | Physics       | Aerodynamics        | c               | y      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    Then I should see "Class Size = 3"
    
    
  @javascript
  Scenario: Teacher views message if no student has completed
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | dave      | My Class      | Radioactivity       | a               | a      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "Completed No student has completed this offering yet."
    
    
  @javascript
  Scenario: Teacher views message if no student has started
    When the following student answers:
      | student | class     | investigation | question_prompt | answer |
      | chuck   | Mechanics | Aerodynamics  | image_          | Y      |
      | chuck   | Mechanics | Aerodynamics  | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "Not yet started All students have started this offering."
    
    
  @javascript
  Scenario: Teacher views message if no student is in progress
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | chuck     | Mechanics      | Aerodynamics        | image_q         | Y      |
      | chuck     | Mechanics      | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "In-progress No students with incomplete progress."
    
    
  @javascript
  Scenario: Teacher should be able to run the report
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | ankur     | Physics       | Aerodynamics        | c               | y      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Run Report" within the first recent activity on the recent activity page
    Then A report window opens of offering "Aerodynamics"
    And I should see "Aerodynamics"
    
    
  @javascript
  Scenario: Anonymous user cannot see recent activity page
    When I log out
    And I am an anonymous user
    And I go to Recent Activity Page
    Then I should be on "my home page"
    
    