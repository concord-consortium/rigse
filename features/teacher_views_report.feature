Feature: Teacher views report

  In order to know how students have done on an offering
  As a teacher
  I want to see a report of their work

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    # for the sake of visual clarity, all correct answers are 'a'
    And the following multiple choice questions exists:
           | prompt | answers | correct_answer |
           | a      | a,b,c,d | a              |
    And there is an image question with the prompt "image_q"
    And the following classes exist:
        | name             | teacher |
        | Intro to bugs    | teacher |
    And the classes "Intro to bugs" are in a school named "Test School"
    And the student "student" is in the class "Intro to bugs"
    And the student "dave" is in the class "Intro to bugs"
    
  Scenario: A teacher views a report of an investigation
    Given the following investigations with multiple choices exist:
        | investigation        | activity | section   | page   | multiple_choices | image_questions | user      |
        | first investigation  | act 3    | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type          | name                 | class            |
        | investigation | first investigation  | Intro to bugs    |
    And the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student   | Intro to bugs | first investigation | a               | a      |
        | student   | Intro to bugs | first investigation | image_q         | Y      |
        | dave      | Intro to bugs | first investigation | a               | b      |
    When I am logged in with the username teacher
    And go to the class page for "Intro to bugs"
    And follow "Display a report" within ".action_menu_activity"
    
  Scenario: A teacher filters a question
    Given the following investigations with multiple choices exist:
        | investigation        | activity | section   | page   | multiple_choices | image_questions | user      |
        | first investigation  | act 3    | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type          | name                 | class            |
        | investigation | first investigation  | Intro to bugs    |
    And the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student   | Intro to bugs | first investigation | a               | a      |
        | student   | Intro to bugs | first investigation | image_q         | Y      |
        | dave      | Intro to bugs | first investigation | a               | b      |
    When I am logged in with the username teacher
    And go to the class page for "Intro to bugs"
    And follow "Display a report" within ".action_menu_activity"
    And I wait 2 seconds
    Then I should see "image_q"
    And I check "filter_Embeddable::MultipleChoice_"
    And I press "Show selected"
    Then I should not see "image_q"
    
  Scenario: A teacher shows all questions
    Given the following investigations with multiple choices exist:
        | investigation        | activity | section   | page   | multiple_choices | image_questions | user      |
        | first investigation  | act 3    | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type          | name                 | class            |
        | investigation | first investigation  | Intro to bugs    |
    And the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student   | Intro to bugs | first investigation | a               | a      |
        | student   | Intro to bugs | first investigation | image_q         | Y      |
        | dave      | Intro to bugs | first investigation | a               | b      |
    When I am logged in with the username teacher
    And go to the class page for "Intro to bugs"
    And follow "Display a report" within ".action_menu_activity"
    And I wait 2 seconds
    Then I should see "image_q"
    And I check "filter_Embeddable::MultipleChoice_"
    And I press "Show selected"
    Then I should not see "image_q"
    And I press "Show all"
    Then I should see "image_q"
    
  Scenario: A teacher views a report of an activity
    Given the following activities with multiple choices exist:
        | activity       | section   | page   | multiple_choices | image_questions | user      |
        | first activity | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type     | name            | class            |
        | activity | first activity  | Intro to bugs    |
    And the following student answers:
        | student   | class         | activity       | question_prompt | answer |
        | student   | Intro to bugs | first activity | a               | a      |
        | student   | Intro to bugs | first activity | image_q         | Y      |
        | dave      | Intro to bugs | first activity | a               | b      |
    When I am logged in with the username teacher
    And go to the class page for "Intro to bugs"
    And follow "Display a report" within ".action_menu_activity"
    Then I should see "image_q"
    And I check "filter_Embeddable::MultipleChoice_"
    And I press "Show selected"
    Then I should not see "image_q"
    And I press "Show all"
    Then I should see "image_q"
    
  Scenario: A teacher prints report of an activity
    Given the following activities with multiple choices exist:
        | activity       | section   | page   | multiple_choices | image_questions | user      |
        | first activity | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type     | name            | class            |
        | activity | first activity  | Intro to bugs    |
    And the following student answers:
        | student   | class         | activity       | question_prompt | answer |
        | student   | Intro to bugs | first activity | a               | a      |
        | student   | Intro to bugs | first activity | image_q         | Y      |
        | dave      | Intro to bugs | first activity | a               | b      |
    When I am logged in with the username teacher
    And go to the class page for "Intro to bugs"
    And follow "Display a report" within ".action_menu_activity"
    And follow "print all users"
    Then I should see "image_q"
    
  Scenario: A teacher views an individual report
    Given the following activities with multiple choices exist:
        | activity       | section   | page   | multiple_choices | image_questions | user      |
        | first activity | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type     | name            | class            |
        | activity | first activity  | Intro to bugs    |
    And the following student answers:
        | student   | class         | activity       | question_prompt | answer |
        | student   | Intro to bugs | first activity | a               | a      |
        | student   | Intro to bugs | first activity | image_q         | Y      |
        | dave      | Intro to bugs | first activity | a               | b      |
    When I am logged in with the username teacher
    And go to the class page for "Intro to bugs"
    And follow "Display a report for the learner"
    Then I should see "image_q"
    
  @javascript
  Scenario: A teacher should see filtered question as checked when all question is displayed in report page
    Given the following activities with multiple choices exist:
        | activity       | section   | page   | multiple_choices | image_questions | user      |
        | first activity | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type     | name            | class            |
        | activity | first activity  | Intro to bugs    |
    And the following student answers:
        | student   | class         | activity       | question_prompt | answer |
        | student   | Intro to bugs | first activity | a               | a      |
        | student   | Intro to bugs | first activity | image_q         | Y      |
        | dave      | Intro to bugs | first activity | a               | b      |
    When I am logged in with the username teacher
    And I go to Instructional Materials page for "Intro to bugs"
    And I follow "Run Report"
    And I apply filter for the question "a" in the report page
    Then I should see question "a" checked when all question is displayed in the report page
    And I close the newly opened window
    
  @javascript
  Scenario: A teacher should see a message if show selected is clicked without selecting any question
    Given the following activities with multiple choices exist:
        | activity       | section   | page   | multiple_choices | image_questions | user      |
        | first activity | section 3 | page 3 | a                | image_q         | teacher |
    And the following assignments exist:
        | type     | name            | class            |
        | activity | first activity  | Intro to bugs    |
    And the following student answers:
        | student   | class         | activity       | question_prompt | answer |
        | student   | Intro to bugs | first activity | a               | a      |
        | student   | Intro to bugs | first activity | image_q         | Y      |
        | dave      | Intro to bugs | first activity | a               | b      |
    When I am logged in with the username teacher
    And I go to Instructional Materials page for "Intro to bugs"
    And I follow "Run Report"
    And I click "Show selected" button on report page
    Then I should see "No questions have been selected." message on the report page
    And I close the newly opened window
    