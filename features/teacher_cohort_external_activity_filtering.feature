Feature: External activities can be filtered by cohort
  As a teacher
  I want to only see external activities for my cohort
  So that I can assign an external activity to my class

  Background:
    Given The default project and jnlp resources exist using factories
    And the following tags exist:
      | scope         | tag             |
      | cohorts       | control         |
      | cohorts       | experiment      |
    And the following teachers exist:
      | login         | password        | cohort_list          |
      | teacher       | teacher         | control              |
      | bteacher      | teacher         | experiment           |
      | cteacher      | teacher         | control, experiment  |
      | dteacher      | teacher         |                      |
      | author        | teacher         |                      |
    And the following classes exist:
      | name        | teacher     |
      | My Class    | teacher     |
      | My b Class  | bteacher    |
      | My c Class  | cteacher    |
      | My d Class  | dteacher    |
    And the following external activities exist:
      | name           | user     | cohort_list         |
      | neither        | teacher  |                     |
      | control        | teacher  | control             |
      | experiment     | teacher  | experiment          |
      | both           | teacher  | control, experiment |
      | b neither b    | bteacher |                     |
      | b control b    | bteacher | control             |
      | b experiment b | bteacher | experiment          |
      | b both b       | bteacher | control, experiment |
      | a neither a    | author   |                     |
      | a control a    | author   | control             |
      | a experiment a | author   | experiment          |
      | a both a       | author   | control, experiment |

  Scenario: External Activities are visible for the control cohort
    Given I login with username: teacher password: teacher
    When I am on the class page for "My Class"
    Then the following should be displayed in the assignables list:
      | name                           |
      | External Activity: neither     |
      | External Activity: control     |
      | External Activity: experiment  |
      | External Activity: both        |
      | External Activity: b neither b |
      | External Activity: b control b |
      | External Activity: b both b    |
      | External Activity: a neither a |
      | External Activity: a control a |
      | External Activity: a both a    |
    And the following should not be displayed in the assignables list:
      | name                              |
      | External Activity: b experiment b |
      | External Activity: a experiment a |

  Scenario: External Activities are visible for the experiment cohort
    Given I login with username: bteacher password: teacher
    When I am on the class page for "My b Class"
    Then the following should be displayed in the assignables list:
      | name                              |
      | External Activity: neither        |
      | External Activity: experiment     |
      | External Activity: both           |
      | External Activity: b neither b    |
      | External Activity: b control b    |
      | External Activity: b experiment b |
      | External Activity: b both b       |
      | External Activity: a neither a    |
      | External Activity: a experiment a |
      | External Activity: a both a       |
    And the following should not be displayed in the assignables list:
      | name                           |
      | External Activity: control     |
      | External Activity: a control a |

  Scenario: External Activities are visible for someone in both cohorts
    Given I login with username: cteacher password: teacher
    When I am on the class page for "My c Class"
    Then the following should be displayed in the assignables list:
      | name                              |
      | External Activity: neither        |
      | External Activity: control        |
      | External Activity: experiment     |
      | External Activity: both           |
      | External Activity: b neither b    |
      | External Activity: b control b    |
      | External Activity: b experiment b |
      | External Activity: b both b       |
      | External Activity: a neither a    |
      | External Activity: a control a    |
      | External Activity: a experiment a |
      | External Activity: a both a       |

  Scenario: External Activities that are untagged are visible to a teacher in neither cohort
    Given I login with username: dteacher password: teacher
    When I am on the class page for "My d Class"
    Then the following should be displayed in the assignables list:
      | name                           |
      | External Activity: neither     |
      | External Activity: b neither b |
      | External Activity: a neither a |
    And the following should not be displayed in the assignables list:
      | name                              |
      | External Activity: control        |
      | External Activity: experiment     |
      | External Activity: both           |
      | External Activity: b control b    |
      | External Activity: b experiment b |
      | External Activity: b both b       |
      | External Activity: a control a    |
      | External Activity: a experiment a |
      | External Activity: a both a       |

