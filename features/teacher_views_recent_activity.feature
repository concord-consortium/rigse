Feature: Teacher can see recent activity
  
  As a teacher
  I should see recent activities of students in all the classes
  In order to make my class more effective
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I login with username: teacher password: password
    
  Scenario: Teacher should see a message if no investigation is assigned to the class
    When I login with username: albert password: password
    And I follow "Recent Activity" within left panel for class navigation
    Then I should see "You need to assign investigations to your classes."
    And I should see "As your students get started, their progress will be displayed here."
    
  Scenario: Teacher should see a message if no activity is assigned to any investigation
    When the following empty investigations exist:
     | name      | user   | offerings_count | publication_status |
     | Digestion | albert | 5               | published          |
    And the following assignments exist:
     | type          | name      | class   |
     | investigation | Digestion | Biology |
    And the student "monty" belongs to class "Biology"
    And I login with username: albert password: password
    Then I should see "As your students get started, their progress will be displayed here."
    
  Scenario: Teacher should see a message if no student is assigned to the class
    When the following teacher and class mapping exists:
      | class_name                   | teacher  |
      | Class_with_no_students       | robert   |
    And I login with username: robert password: password
    Then I should see "As your students get started, their progress will be displayed here."
    
  @javascript
  Scenario: Teacher should see standalone activity 
    When the Activity "Algebra" is assigned to the class "Mathematics"
    And the following student answers:
      | student   | class         | activity            | question_prompt | answer |
      | taylor    | Mathematics   | Algebra             | f               | y      |
    And I follow "Recent Activity" within left panel for class navigation
    Then I should see "Mathematics: Algebra"
    
  @javascript
  Scenario: Teacher should not see teacher only activity
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | ross      | Physics       | Aerodynamics        | d               | y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "Air activity"
    And I should not see "Aeroplane"
    
  Scenario: Teacher views the class at the top where most recent activity occurred
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And the Activity "Algebra" is assigned to the class "Mathematics"
    And the following student answers:
      | student   | class         | activity            | question_prompt | answer |
      | taylor    | Mathematics   | Algebra             | f               | y      |
    And I follow "Recent Activity" within left panel for class navigation
    Then "Mathematics" should appear before "Physics"
    
  @javascript
  Scenario: Teacher should view the progress bar for recent investigation
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | ross      | Physics       | Aerodynamics        | c               | y      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    Then I should see the progress of the student within the first recent activity on the recent activity page
    
  @javascript
  Scenario: Teacher should view the students grouped by progress
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | chuck     | Mechanics     | Aerodynamics        | image_q         | Y      |
      | chuck     | Mechanics     | Aerodynamics        | c               | Y      |
      | ross      | Physics       | Aerodynamics        | c               | y      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "Taylor, Ross" in In-progress on the recent activity page
    And I should see "Completed Smith, Chuck"
    And I should see "Not Yet Started Done, Shon"
    
  Scenario: Teacher views class size
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | ross      | Physics       | Aerodynamics        | c               | y      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    Then I should see "Class Size = 4"
    
  @javascript
  Scenario: Teacher views message if no student has completed
    When the Activity "Algebra" is assigned to the class "Mathematics"
    And the following student answers:
      | student   | class         | activity            | question_prompt | answer |
      | taylor    | Mathematics   | Algebra             | f               | y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "Completed No student has completed this investigation yet."
    
  @javascript
  Scenario: Teacher views message if no student has started
    When the following student answers:
      | student | class     | investigation | question_prompt | answer |
      | chuck   | Mechanics | Aerodynamics  | image_q         | Y      |
      | chuck   | Mechanics | Aerodynamics  | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "Not Yet Started All students have started this investigation."
    
  @javascript
  Scenario: Teacher views message if no student is in progress
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | chuck     | Mechanics      | Aerodynamics        | image_q         | Y      |
      | chuck     | Mechanics      | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Show detail" within the first recent activity on the recent activity page
    Then I should see "In Progress No students with incomplete progress."
    
  @javascript
  Scenario: Teacher should be able to run the report
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | ross      | Physics       | Aerodynamics        | c               | y      |
      | chuck     | Physics       | Aerodynamics        | image_q         | Y      |
      | chuck     | Physics       | Aerodynamics        | c               | Y      |
    And I follow "Recent Activity" within left panel for class navigation
    And I follow "Run Report" within the first recent activity on the recent activity page
    Then A report window opens of offering "Aerodynamics"
    And I should see "Aerodynamics"
    
  Scenario: Anonymous user cannot see recent activity page
    When I log out
    And I am an anonymous user
    And I try to go to Recent Activity Page
    Then I should be on "my home page"
    