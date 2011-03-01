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

    And The following investigation exists:
       | investigation | activity | section   | page   | multiple_choices |
       | test inv.     | act 1    | section 1 | page 1 | a, b             |
       | test inv.     | act 2    | section 1 | page 1 | c, d             |

    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |

    And the following classes exist:
       | name          | teacher |
       | Intro to bugs | teacher |

    # we expect student a = 100% correct, b = 50%, c = 0%
    And the following students exist:
        | login     | password  | class         |
        | student_a | student_a | Intro to bugs |
        | student_b | student_b | Intro to bugs |
        | student_c | student_c | Intro to bugs |

    And the following assignments exist:
       | investigation | class         |
       | test inv.     | Intro to bugs |


  Scenario: A student answers all questions, and gets them all correct
    Given the following student answers:
       | student   | class         | investigation | question_prompt | answer |
       | student_a | Intro to bugs | test inv.     | a               | a      |
       | student_a | Intro to bugs | test inv.     | b               | a      |
       | student_a | Intro to bugs | test inv.     | c               | a      |
       | student_a | Intro to bugs | test inv.     | d               | a      |
    Then "student_a" should have 4 answers for "test inv." in "Intro to Bugs"
    And "student_a" should have answered 100% of the questions for "test inv." in "Intro to Bugs"
    And "student_a" should have 100% of the qeustions correctly for "test inv." in "Intro to Bugs"

  Scenario: A student answers half of the questions, and gets them both right
    Given the following student answers:
       | student   | class         | investigation | question_prompt | answer |
       | student_a | Intro to bugs | test inv.     | a               | a      |
       | student_a | Intro to bugs | test inv.     | b               | a      |
    Then "student_a" should have 2 answers for "test inv." in "Intro to Bugs"
    And "student_a" should have answered 50% of the questions for "test inv." in "Intro to Bugs"
    And "student_a" should have 50% of the qeustions correctly for "test inv." in "Intro to Bugs"
  
  Scenario: A student answers 3/4 of the questions, and gets them all wrong
    Given the following student answers:
       | student   | class         | investigation | question_prompt | answer |
       | student_a | Intro to bugs | test inv.     | a               | b      |
       | student_a | Intro to bugs | test inv.     | b               | b      |
       | student_a | Intro to bugs | test inv.     | c               | b      |
    Then "student_a" should have 3 answers for "test inv." in "Intro to Bugs"
    And "student_a" should have answered 75% of the questions for "test inv." in "Intro to Bugs"
    And "student_a" should have 0% of the qeustions correctly for "test inv." in "Intro to Bugs"
  
  Scenario: A student answers none of the questions, and gets them all wrong
    Given the following student answers:
       | student   | class         | investigation | question_prompt | answer |
    Then "student_a" should have 0 answers for "test inv." in "Intro to Bugs"
    And "student_a" should have answered 0% of the questions for "test inv." in "Intro to Bugs"
    And "student_a" should have 0% of the qeustions correctly for "test inv." in "Intro to Bugs"

