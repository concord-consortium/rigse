Feature: Teacher views report from the instructional materials page of a class
  
  As a teacher
  I want to see report from the instructional materials of a class
  In order to see the attempts of students.

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    And I go to Instructional Materials page for "My Class"
    
    
  @javascript
  Scenario: Teacher should see report for activity
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | c               | y      |
      | chuck     | My Class       | Aerodynamics        | a               | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Air activity"
    Then A report window opens of offering "Aerodynamics"
    Then Report page should have student name "Dave Doe" in answered section for the question "a"
    And Report page should have student name "Chuck Smith" in answered section for the question "a"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Teacher should see report for student
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | c               | y      |
      | chuck     | My Class       | Aerodynamics        | image_q         | Y      |
      | chuck     | My Class       | Aerodynamics        | c               | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Doe, Dave"
    Then Report page should have content "Dave Doe"
    And Report page should not have content "Chuck Smith"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Teacher should see report for student and corresponding activity
    When the following student answers:
      | student   | class         | investigation       | question_prompt | answer |
      | dave      | My Class      | Aerodynamics        | c               | y      |
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
      | dave      | My Class       | Aerodynamics        | c               | y      |
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
    Then Report page should not have content "image_q"
    And I close the newly opened window
    And I click progress bar on the instructional materials page for the student "dave" and activity "Air activity"
    Then Report page should not have content "image_q"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Report filtered state should be maintained if filter is applied at activity level,student level and student's activity level
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | c               | y      |
      | dave      | My Class       | Aerodynamics        | image_q         | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Doe, Dave"
    And I apply filter for the question "a" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Air activity"
    And I apply filter for the question "a" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I click progress bar on the instructional materials page for the student "dave" and activity "Air activity"
    And I apply filter for the question "a" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Filtering the activity report should effect main report
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | c               | y      |
      | dave      | My Class       | Aerodynamics        | image_q         | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Air activity"
    And I apply filter for the question "a" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    
    
  @javascript
  Scenario: Filtering the main report should effect activity
    When the following student answers:
      | student   | class          | investigation       | question_prompt | answer |
      | dave      | My Class       | Aerodynamics        | c               | y      |
      | dave      | My Class       | Aerodynamics        | image_q         | Y      |
    And I go to Instructional Materials page for "My Class"
    And I follow "Run Report"
    And I apply filter for the question "a" in the report page
    And I close the newly opened window
    And I go to Instructional Materials page for "My Class"
    And I follow "Air activity"
    Then Report page should not have content "imadge_q"
    And I close the newly opened window
    
    