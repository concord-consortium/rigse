Feature: External activities can be filtered by cohort
  As a teacher
  I want to only see external activities for my cohort
  So that I can assign an external activity to my class

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following tags exist:
      | scope         | tag             |
      | cohorts       | control         |
      | cohorts       | experiment      |
    And the following external activities exist:
      | name           | user      | cohort_list         |
      | neither        | teacher   |                     |
      | control        | teacher   | control             |
      | experiment     | teacher   | experiment          |
      | both           | teacher   | control, experiment |
      | b neither b    | albert    |                     |
      | b control b    | albert    | control             |
      | b experiment b | albert    | experiment          |
      | b both b       | albert    | control, experiment |
      | a neither a    | jonson    |                     |
      | a control a    | jonson    | control             |
      | a experiment a | jonson    | experiment          |
      | a both a       | jonson    | control, experiment |

  Scenario: External Activities are visible for the control cohort
    Given I am logged in with the username teacher
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
    Given I am logged in with the username albert
    When I am on the class page for "Biology"
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
    Given I am logged in with the username robert
    When I am on the class page for "Physics"
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
    Given I am logged in with the username peterson
    When I am on the class page for "class_with_no_assignment"
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

