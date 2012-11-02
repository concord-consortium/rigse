Feature: Teacher views report from the instructional materials page of a class
  
  As a teacher
  I want to see report from the instructional materials of a class
  In order to see the attempts of students.

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         | Nash      |
    And the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    And the teachers "teacher" are in a school named "Harvard School"
    And the following semesters exist:
      | name     |
      | Fall     |
      | Spring   |
    And the following classes exist:
      | name        | teacher | class_word | semester |
      | My Class    | teacher | my_classes | Fall     |
    And the classes "My Class" are in a school named "Harvard School"
    And the following multiple choice questions exists:
      | prompt | answers | correct_answer |
      | a      | a,b,c,d | a              |
    And there is an image question with the prompt "image_q"
    And the following investigations with multiple choices exist:
      | investigation        | activity       | section   | page   | multiple_choices | image_questions | user      | activity_teacher_only |
      | Aerodynamics         | Air activity   | section a | page 1 | a                | image_q         | teacher   | false                 |
    And the following assignments exist:
      | type          | name                 | class       |
      | investigation | Aerodynamics         | My Class    |
      And the following students exist:
      | login     | password  | first_name | last_name |
      | dave      | student   | Dave       | Doe       |
      | chuck     | student   | Chuck      | Smith     |
    And the student "dave" belongs to class "My Class"
    And the student "chuck" belongs to class "My Class"
    And I am logged in with the username teacher
    And I go to Instructional Materials page for "My Class"
    
    
  @javascript
  Scenario: Teacher should see report for activity
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | a               | y      |
      | chuck     | My Class       | Aerodynamics        | a               | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Air activity"
    Then A report window opens of offering "Aerodynamics"
    Then Report page should have student name "Dave Doe" in answered section for the question "c"
    And Report page should have student name "Chuck Smith" in answered section for the question "c"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Teacher should see report for student
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | a               | y      |
      | chuck     | My Class       | Aerodynamics        | image_q         | Y      |
      | chuck     | My Class       | Aerodynamics        | a               | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Doe, Dave"
    Then Report page should have content "Dave Doe"
    And Report page should not have content "Chuck Smith"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Teacher should see report for student and corresponding activity
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | dave      | My Class      | Aerodynamics        | a               | y      |
    And I go to Instructional Materials page for "My Class"
    And I click progress bar on the instructional materials page for the student "dave" and activity "Air activity"
    Then Report page should have content "Air activity"
    And Report page should have content "Dave Doe"
    And Report page should not have content "Atmosphere"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Report filtered state should be maintained if filter is applied at investigation level
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | a               | y      |
      | dave      | My Class       | Aerodynamics        | image_q         | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    And I apply filter for the question "a" in the report page
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    And I follow "Doe, Dave"
    Then Report page should not have content "image_q"
    And I close the newly opened window
    And I follow "Air activity"
    Then Report page should have content "image_q"
    And I close the newly opened window
    And I click progress bar on the instructional materials page for the student "dave" and activity "Air activity"
    Then Report page should have content "image_q"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Report filtered state should be maintained if filter is applied at activity level,student level and student's activity level
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | a               | y      |
      | dave      | My Class       | Aerodynamics        | image_q         | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Doe, Dave"
    And I apply filter for the question "c" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Air activity"
    And I apply filter for the question "c" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I click progress bar on the instructional materials page for the student "dave" and activity "Air activity"
    And I apply filter for the question "c" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Filtering the activity report should not effect main report
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | a               | y      |
      | dave      | My Class       | Aerodynamics        | image_q         | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Air activity"
    And I apply filter for the question "c" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    
    