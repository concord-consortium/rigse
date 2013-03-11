Feature: Resource pages can be filtered by cohort
  As a teacher
  I want to only see resource pages for my cohort
  So that I can assign a resource page to my class

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    And the following tags exist:
      | scope         | tag             |
      | cohorts       | control         |
      | cohorts       | experiment      |
    And the following classes exist:
      | name        | teacher     |
      | My Class    | teacher    |
      | My b Class  | albert    |
      | My c Class  | robert    |
      | My d Class  | peterson    |
    And the following resource pages exist:
      | name           | user     | cohort_list         |
      | neither        | teacher |                     |
      | control        | teacher | control             |
      | experiment     | teacher | experiment          |
      | both           | teacher | control, experiment |
      | b neither b    | albert  |                     |
      | b control b    | albert  | control             |
      | b experiment b | albert  | experiment          |
      | b both b       | albert  | control, experiment |
      | a neither a    | jonson  |                     |
      | a control a    | jonson  | control             |
      | a experiment a | jonson  | experiment          |
      | a both a       | jonson  | control, experiment |

  Scenario: Resource Pages are visible for the control cohort
    Given I am logged in with the username teacher
    When I am on the class page for "My Class"
    Then the following should be displayed in the assignables list:
      | name                       |
      | Resource Page: neither     |
      | Resource Page: control     |
      | Resource Page: experiment  |
      | Resource Page: both        |
      | Resource Page: b neither b |
      | Resource Page: b control b |
      | Resource Page: b both b    |
      | Resource Page: a neither a |
      | Resource Page: a control a |
      | Resource Page: a both a    |
    And the following should not be displayed in the assignables list:
      | name                          |
      | Resource Page: b experiment b |
      | Resource Page: a experiment a |

  Scenario: Resource Pages are visible for the experiment cohort
    Given I am logged in with the username albert
    When I am on the class page for "My b Class"
    Then the following should be displayed in the assignables list:
      | name                          |
      | Resource Page: neither        |
      | Resource Page: experiment     |
      | Resource Page: both           |
      | Resource Page: b neither b    |
      | Resource Page: b control b    |
      | Resource Page: b experiment b |
      | Resource Page: b both b       |
      | Resource Page: a neither a    |
      | Resource Page: a experiment a |
      | Resource Page: a both a       |
    And the following should not be displayed in the assignables list:
      | name                       |
      | Resource Page: control     |
      | Resource Page: a control a |

  Scenario: Resource Pages are visible for someone in both cohorts
    Given I am logged in with the username robert
    When I am on the class page for "My c Class"
    Then the following should be displayed in the assignables list:
      | name                          |
      | Resource Page: neither        |
      | Resource Page: control        |
      | Resource Page: experiment     |
      | Resource Page: both           |
      | Resource Page: b neither b    |
      | Resource Page: b control b    |
      | Resource Page: b experiment b |
      | Resource Page: b both b       |
      | Resource Page: a neither a    |
      | Resource Page: a control a    |
      | Resource Page: a experiment a |
      | Resource Page: a both a       |

  Scenario: Resource Pages that are untagged are visible to a teacher in neithers
    Given I am logged in with the username peterson
    When I am on the class page for "My d Class"
    Then the following should be displayed in the assignables list:
      | name                       |
      | Resource Page: neither     |
      | Resource Page: b neither b |
      | Resource Page: a neither a |
    And the following should not be displayed in the assignables list:
      | name                          |
      | Resource Page: control        |
      | Resource Page: experiment     |
      | Resource Page: both           |
      | Resource Page: b control b    |
      | Resource Page: b experiment b |
      | Resource Page: b both b       |
      | Resource Page: a control a    |
      | Resource Page: a experiment a |
      | Resource Page: a both a       |

