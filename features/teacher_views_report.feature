Feature: Teacher views report

  In order to know how students have done on an offering
  As a teacher
  I want to see a report of their work

  Background:
    Given The default project and jnlp resources exist using factories

    # for the sake of visual clarity, all correct answers are 'a'
    And the following teachers exist:
       | login     | password  |
       | teacher_a | teacher_a |
    And the following multiple choice questions exists:
           | prompt | answers | correct_answer |
           | a      | a,b,c,d | a              |
    And there is an image question with the prompt "image_q"
    And The following investigation exists:
       | investigation        | activity | section   | page   | multiple_choices | image_questions | user      |
       | first investigation  | act 3    | section 3 | page 3 | a                | image_q         | teacher_a |
    And the following classes exist:
        | name             | teacher |
        | Intro to bugs    | teacher_a |
    And the classes "Intro to bugs" are in a school named "Test School"
    And the following students exist:
         | login     | password  | first_name | last_name |
         | student_a | student_a | Jack       | Doe       |
         | student_b | student_b | Jill       | Smith     |
    And the student "student_a" is in the class "Intro to bugs"
    And the student "student_b" is in the class "Intro to bugs"
    And the following assignments exist:
          | investigation        | class            |
          | first investigation  | Intro to bugs    |

  @selenium
  Scenario: A student answers all questions, and gets them all correct
    Given the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student_a | Intro to bugs | first investigation | a               | a      |
        | student_a | Intro to bugs | first investigation | image_q         | Y      |
        | student_b | Intro to bugs | first investigation | a               | b      |
    When I login with username: teacher_a password: teacher_a
    And go to the class page for "Intro to bugs"
    And follow "Display a report" within ".action_menu_activity"
