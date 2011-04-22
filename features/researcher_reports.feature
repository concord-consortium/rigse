Feature: Investigations can be reported on
  So that researchers can report on activies run by students
  As a researcher
  I want to print several kinds of reports
  So that our work can be validated
  Which will support the funding of future projects

  Background:
    Given The default project and jnlp resources exist using factories

    # for the sake of visual clarity, all correct answers are 'a'
    And the following multiple choice questions exists:
           | prompt | answers | correct_answer |
           | a      | a,b,c,d | a              |
           | b      | a,b,c,d | a              |
           | c      | a,b,c,d | a              |
           | d      | a,b,c,d | a              |
           | e      | a,b,c,d | a              |
           | f      | a,b,c,d | a              |
           | b_a    | a,b,c,d | a              |
           | b_b    | a,b,c,d | a              |
           | b_c    | a,b,c,d | a              |
           | b_d    | a,b,c,d | a              |
           | b_e    | a,b,c,d | a              |

    And there is an image question with the prompt "image_q"

    And The following investigation exists:
       | investigation        | activity | section   | page   | multiple_choices | image_questions |
       | first investigation  | act 1    | section 1 | page 1 | a, b             |                 |
       | first investigation  | act 2    | section 2 | page 2 | c, d             |                 |
       | second investigation | act 3    | section 3 | page 3 | b_a, b_b         | image_q         |
       | second investigation | act 4    | section 4 | page 4 | b_c, b_d         |                 |


    And the following teachers exist:
       | login     | password  |
       | teacher_a | teacher_a |
       | teacher_b | teacher_a |


    And the following classes exist:
        | name             | teacher |
        | Intro to bugs    | teacher_a |
        | Intro to flowers | teacher_b |

    And the classes "Intro to bugs, Intro to flowers" are in a school named "Test School"
    
    And the following students exist:
         | login     | password  | first_name | last_name |
         | student_a | student_a | Jack       | Doe       |
         | student_b | student_b | Jill       | Smith     |
         | student_c | student_c | Joe        | Pfifer    |

    And the student "student_a" is in the class "Intro to bugs"
    And the student "student_b" is in the class "Intro to bugs"
    And the student "student_a" is in the class "Intro to flowers"
    And the student "student_b" is in the class "Intro to flowers"

    And the following assignments exist:
          | type          | name                 | class            |
          | investigation | first investigation  | Intro to bugs    |
          | investigation | second investigation | Intro to bugs    |
          | investigation | second investigation | Intro to flowers |

  Scenario: A student answers all questions, and gets them all correct
    Given the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student_a | Intro to bugs | first investigation | a               | a      |
        | student_a | Intro to bugs | first investigation | b               | a      |
        | student_a | Intro to bugs | first investigation | c               | a      |
        | student_a | Intro to bugs | first investigation | d               | a      |
    Then "student_a" should have 4 answers for "first investigation" in "Intro to Bugs"
    And "student_a" should have answered 100% of the questions for "first investigation" in "Intro to Bugs"
    And "student_a" should have 100% of the questions correctly for "first investigation" in "Intro to Bugs"

  Scenario: A student answers half of the questions, and gets them both right
    Given the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student_a | Intro to bugs | first investigation | a               | a      |
        | student_a | Intro to bugs | first investigation | b               | a      |
    Then "student_a" should have 2 answers for "first investigation" in "Intro to Bugs"
    And "student_a" should have answered 50% of the questions for "first investigation" in "Intro to Bugs"
    And "student_a" should have 50% of the questions correctly for "first investigation" in "Intro to Bugs"

  Scenario: A student answers 3/4 of the questions, and gets them all wrong
    Given the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student_a | Intro to bugs | first investigation | a               | b      |
        | student_a | Intro to bugs | first investigation | b               | b      |
        | student_a | Intro to bugs | first investigation | c               | b      |
    Then "student_a" should have 3 answers for "first investigation" in "Intro to Bugs"
    And  "student_a" should have answered 75% of the questions for "first investigation" in "Intro to Bugs"
    And  "student_a" should have 0% of the questions correctly for "first investigation" in "Intro to Bugs"

  Scenario: A student answers none of the questions, and gets them all wrong
    Given the following student answers:
       | student   | class         | investigation | question_prompt | answer |
    Then "student_a" should have 0 answers for "first investigation" in "Intro to Bugs"
    And "student_a" should have answered 0% of the questions for "first investigation" in "Intro to Bugs"
    And "student_a" should have 0% of the questions correctly for "first investigation" in "Intro to Bugs"

  Scenario: A student changes their answer from incorrect, to correct.
    Given the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student_a | Intro to bugs | first investigation | a               | b      |
        | student_a | Intro to bugs | first investigation | a               | a      |
        | student_a | Intro to bugs | first investigation | c               | b      |
    Then "student_a" should have 3 answers for "first investigation" in "Intro to Bugs"
    And  "student_a" should have answered 75% of the questions for "first investigation" in "Intro to Bugs"
    And  "student_a" should have 25% of the questions correctly for "first investigation" in "Intro to Bugs"

  Scenario: Confusions about an answered, seen, and unseen questions
    Given the following student answers:
        | student   | class         | investigation       | question_prompt | answer |
        | student_a | Intro to bugs | first investigation | a               | b      |
        | student_a | Intro to bugs | first investigation | b               | b      |
    Then "student_a" should have answered 50% of the questions for "first investigation" in "Intro to Bugs"
    And "student_a" should have 0% of the questions correctly for "first investigation" in "Intro to Bugs"
    And "student_a" should have 2 answers for "first investigation" in "Intro to Bugs"

  Scenario: Comprehensive report tests for two investigations and two students
    Given the following student answers:
       | student   | class            | investigation        | question_prompt | answer |
       | student_a | Intro to bugs    | first investigation  | a               | a      |
       | student_a | Intro to bugs    | first investigation  | b               | a      |
       | student_a | Intro to bugs    | first investigation  | c               | a      |
       | student_a | Intro to bugs    | first investigation  | d               | a      |
       | student_b | Intro to bugs    | first investigation  | b               | a      |
       | student_b | Intro to bugs    | first investigation  | c               | b      |
       | student_b | Intro to bugs    | first investigation  | d               | b      |
       | student_a | Intro to bugs    | second investigation | b_a             | a      |
       | student_a | Intro to bugs    | second investigation | b_b             | a      |
       | student_a | Intro to bugs    | second investigation | b_c             | a      |
       | student_a | Intro to bugs    | second investigation | b_d             | a      |
       | student_a | Intro to bugs    | second investigation | image_q         | Y      |
       | student_b | Intro to bugs    | second investigation | b_a             | a      |
       | student_b | Intro to bugs    | second investigation | b_b             | a      |
       | student_b | Intro to bugs    | second investigation | b_c             | b      |
       | student_b | Intro to bugs    | second investigation | b_d             | b      |
       | student_b | Intro to bugs    | second investigation | image_q         | Y      |
       | student_a | Intro to flowers | second investigation | b_a             | a      |
       | student_a | Intro to flowers | second investigation | b_b             | a      |
       | student_a | Intro to flowers | second investigation | b_c             | a      |
       | student_a | Intro to flowers | second investigation | b_d             | a      |
       | student_a | Intro to flowers | second investigation | image_q         | Y      |
       | student_b | Intro to flowers | second investigation | b_a             | b      |
       | student_b | Intro to flowers | second investigation | b_b             | b      |


    Then "student_a" should have 4 answers for "first investigation" in "Intro to Bugs"

    And  "student_a" should have answered 100% of the questions for "first investigation" in "Intro to Bugs"
    And  "student_a" should have 100% of the questions correctly for "first investigation" in "Intro to Bugs"

    And  "student_b" should have 3 answers for "first investigation" in "Intro to Bugs"
    And  "student_b" should have answered 75% of the questions for "first investigation" in "Intro to Bugs"
    And  "student_b" should have 25% of the questions correctly for "first investigation" in "Intro to Bugs"

    And  "student_a" should have 5 answers for "second investigation" in "Intro to Bugs"
    And  "student_a" should have answered 100% of the questions for "second investigation" in "Intro to Bugs"
    And  "student_a" should have 100% of the questions correctly for "second investigation" in "Intro to Bugs"

    And  "student_b" should have 5 answers for "second investigation" in "Intro to Bugs"
    And  "student_b" should have answered 100% of the questions for "second investigation" in "Intro to Bugs"
    And  "student_b" should have 50% of the questions correctly for "second investigation" in "Intro to Bugs"

    And  "student_a" should have 5 answers for "second investigation" in "Intro to flowers"
    And  "student_a" should have answered 100% of the questions for "second investigation" in "Intro to flowers"
    And  "student_a" should have 100% of the questions correctly for "second investigation" in "Intro to flowers"

    And  "student_b" should have 2 answers for "second investigation" in "Intro to flowers"
    And  "student_b" should have answered 40% of the questions for "second investigation" in "Intro to flowers"
    And  "student_b" should have 0% of the questions correctly for "second investigation" in "Intro to flowers"

    # Record a complex report, and ensure that it looks the same
    # time after time.
    And  a recording of a report for "first investigation"
    Then the report generated for "first investigation" should match recorded data

    And  the report generated for "second investigation" should have (3) links to blobs
    And  the usage report for "first investigation" should have (3) answers for "student_b"

  @pending
  Scenario: a student has a record for an answer, which wasn't assigned ...
  # Failing, because question #e wasn't part of the investigation. (!) woah.

  Scenario: a students answers appear in the correct order in the spreadsheet
  @pending

  @current
  Scenario: Comparing the total assessments completed, with total completed for each activity
    Given the following student answers:
       | student   | class            | investigation        | question_prompt | answer |
       | student_a | Intro to bugs    | first investigation  | a               | a      |
       | student_a | Intro to bugs    | first investigation  | b               | a      |
       | student_a | Intro to bugs    | first investigation  | c               | a      |
       | student_a | Intro to bugs    | first investigation  | d               | a      |

     Then "student_a" should have 4 answers for "first investigation" in "Intro to bugs"
     And  "student_a" should have completed (2) assessments for Activity "act 1" in "Intro to bugs"
     And  "student_a" should have completed (2) assessments for Activity "act 2" in "Intro to bugs"
