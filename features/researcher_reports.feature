Feature: Investigations can be reported on
  So that researchers can report on activies run by students
  As a researcher
  I want to print several kinds of reports
  So that our work can be validated
  Which will support the funding of future projects

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded

    # for the sake of visual clarity, all correct answers are 'a'
    And the following multiple choice questions exists:
           | prompt | answers | correct_answer |
           | b_a    | a,b,c,d | a              |
           | b_b    | a,b,c,d | a              |
           | b_c    | a,b,c,d | a              |
           | b_d    | a,b,c,d | a              |
           | b_e    | a,b,c,d | a              |

    And there is an image question with the prompt "image_q"

    And the following investigations with multiple choices exist:
       | investigation        | activity | section   | page      | multiple_choices | image_questions |
       | first investigation  | act 1    | section 1 | fi page 1 | a, b             |                 |
       | first investigation  | act 2    | section 2 | fi page 2 | c, d             |                 |
       | second investigation | act 3    | section 3 | si page 3 | b_a, b_b         | image_q         |
       | second investigation | act 4    | section 4 | si page 4 | b_c, b_d         |                 |

    And the following assignments exist:
          | type          | name                 | class       |
          | investigation | first investigation  | My Class    |
          | investigation | second investigation | My Class    |
          | investigation | second investigation | Biology     |

  Scenario: A student answers all questions, and gets them all correct
    Given the following student answers:
        | student | class    | investigation       | question_prompt | answer |
        | student | My Class | first investigation | a               | a      |
        | student | My Class | first investigation | b               | a      |
        | student | My Class | first investigation | c               | a      |
        | student | My Class | first investigation | d               | a      |
    Then "student" should have 4 answers for "first investigation" in "My Class"
    And "student" should have answered 100% of the questions for "first investigation" in "My Class"
    And "student" should have 100% of the questions correctly for "first investigation" in "My Class"

  Scenario: A student answers half of the questions, and gets them both right
    Given the following student answers:
        | student   | class    | investigation       | question_prompt | answer |
        | student   | My Class | first investigation | a               | a      |
        | student   | My Class | first investigation | b               | a      |
    Then "student" should have 2 answers for "first investigation" in "My Class"
    And "student" should have answered 50% of the questions for "first investigation" in "My Class"
    And "student" should have 50% of the questions correctly for "first investigation" in "My Class"

  Scenario: A student answers 3/4 of the questions, and gets them all wrong
    Given the following student answers:
        | student   | class    | investigation       | question_prompt | answer |
        | student   | My Class | first investigation | a               | b      |
        | student   | My Class | first investigation | b               | b      |
        | student   | My Class | first investigation | c               | b      |
    Then "student" should have 3 answers for "first investigation" in "My Class"
    And  "student" should have answered 75% of the questions for "first investigation" in "My Class"
    And  "student" should have 0% of the questions correctly for "first investigation" in "My Class"

  Scenario: A student answers none of the questions, and gets them all wrong
    Given the following student answers:
       | student   | class         | investigation | question_prompt | answer |
    Then "student" should have 0 answers for "first investigation" in "My Class"
    And "student" should have answered 0% of the questions for "first investigation" in "My Class"
    And "student" should have 0% of the questions correctly for "first investigation" in "My Class"

  Scenario: A student changes their answer from incorrect, to correct.
    Given the following student answers:
        | student   | class    | investigation       | question_prompt | answer |
        | student   | My Class | first investigation | a               | b      |
        | student   | My Class | first investigation | a               | a      |
        | student   | My Class | first investigation | c               | b      |
    Then "student" should have 3 answers for "first investigation" in "My Class"
    And  "student" should have answered 75% of the questions for "first investigation" in "My Class"
    And  "student" should have 25% of the questions correctly for "first investigation" in "My Class"

  Scenario: Confusions about an answered, seen, and unseen questions
    Given the following student answers:
        | student | class    | investigation       | question_prompt | answer |
        | student | My Class | first investigation | a               | b      |
        | student | My Class | first investigation | b               | b      |
    Then "student" should have answered 50% of the questions for "first investigation" in "My Class"
    And "student" should have 0% of the questions correctly for "first investigation" in "My Class"
    And "student" should have 2 answers for "first investigation" in "My Class"

  Scenario: Comprehensive report tests for two investigations and two students
    Given PENDING yaml dumping on hudson and local machines differ. 
    Given the following student answers:
       | student | class       | investigation        | question_prompt | answer |
       | student | My Class    | first investigation  | a               | a      |
       | student | My Class    | first investigation  | b               | a      |
       | student | My Class    | first investigation  | c               | a      |
       | student | My Class    | first investigation  | d               | a      |
       | dave    | My Class    | first investigation  | b               | a      |
       | dave    | My Class    | first investigation  | c               | b      |
       | dave    | My Class    | first investigation  | d               | b      |
       | student | My Class    | second investigation | b_a             | a      |
       | student | My Class    | second investigation | b_b             | a      |
       | student | My Class    | second investigation | b_c             | a      |
       | student | My Class    | second investigation | b_d             | a      |
       | student | My Class    | second investigation | image_q         | Y      |
       | dave    | My Class    | second investigation | b_a             | a      |
       | dave    | My Class    | second investigation | b_b             | a      |
       | dave    | My Class    | second investigation | b_c             | b      |
       | dave    | My Class    | second investigation | b_d             | b      |
       | dave    | My Class    | second investigation | image_q         | Y      |
       | student | Biology     | second investigation | b_a             | a      |
       | student | Biology     | second investigation | b_b             | a      |
       | student | Biology     | second investigation | b_c             | a      |
       | student | Biology     | second investigation | b_d             | a      |
       | student | Biology     | second investigation | image_q         | Y      |
       | dave    | Biology     | second investigation | b_a             | b      |
       | dave    | Biology     | second investigation | b_b             | b      |


    Then "student" should have 4 answers for "first investigation" in "My Class"

    And  "student" should have answered 100% of the questions for "first investigation" in "My Class"
    And  "student" should have 100% of the questions correctly for "first investigation" in "My Class"

    And  "dave" should have 3 answers for "first investigation" in "My Class"
    And  "dave" should have answered 75% of the questions for "first investigation" in "My Class"
    And  "dave" should have 25% of the questions correctly for "first investigation" in "My Class"

    And  "student" should have 5 answers for "second investigation" in "My Class"
    And  "student" should have answered 100% of the questions for "second investigation" in "My Class"
    And  "student" should have 100% of the questions correctly for "second investigation" in "My Class"

    And  "dave" should have 5 answers for "second investigation" in "My Class"
    And  "dave" should have answered 100% of the questions for "second investigation" in "My Class"
    And  "dave" should have 50% of the questions correctly for "second investigation" in "My Class"

    And  "student" should have 5 answers for "second investigation" in "Biology"
    And  "student" should have answered 100% of the questions for "second investigation" in "Biology"
    And  "student" should have 100% of the questions correctly for "second investigation" in "Biology"

    And  "dave" should have 2 answers for "second investigation" in "Biology"
    And  "dave" should have answered 40% of the questions for "second investigation" in "Biology"
    And  "dave" should have 0% of the questions correctly for "second investigation" in "Biology"

    # Record a complex report, and ensure that it looks the same
    # time after time.
    And  a recording of a report for "first investigation"
    Then the report generated for "first investigation" should match recorded data

    And  the report generated for "second investigation" should have (3) links to blobs
    And  the usage report for "first investigation" should have (3) answers for "dave"

  @pending
  Scenario: a student has a record for an answer, which wasn't assigned ...
  # Failing, because question #e wasn't part of the investigation. (!) woah.

  Scenario: a students answers appear in the correct order in the spreadsheet
  @pending

  @current
  Scenario: Comparing the total assessments completed, with total completed for each activity
    Given the following student answers:
       | student   | class       | investigation        | question_prompt | answer |
       | student   | My Class    | first investigation  | a               | a      |
       | student   | My Class    | first investigation  | b               | a      |
       | student   | My Class    | first investigation  | c               | a      |
       | student   | My Class    | first investigation  | d               | a      |

     Then "student" should have 4 answers for "first investigation" in "My Class"
     And  "student" should have completed (2) assessments for Activity "act 1" in "My Class"
     And  "student" should have completed (2) assessments for Activity "act 2" in "My Class"

  Scenario: Interacting with the researcher report UI
    Given the following researchers exist:
      | login      | password   | email                  |
      | researcher | researcher | researcher@concord.org |

    And the following student answers:
        | student | class    | investigation       | question_prompt | answer |
        | student | My Class | first investigation | a               | b      |
        | student | My Class | first investigation | a               | a      |
        | student | My Class | first investigation | c               | b      |

    And a mocked spreadsheet library

    And I am logged in with the username researcher
    And I am on the researcher reports page
    Then I should see "You have selected:"
    When I press "Apply Filters"
    Then I should see "You have selected:"
    When I press "Usage Report"
    Then I should receive an Excel spreadsheet
    When I am on the researcher reports page
    And I press "Details Report"
    Then I should receive an Excel spreadsheet
