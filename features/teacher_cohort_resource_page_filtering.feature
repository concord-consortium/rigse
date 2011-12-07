#itsisu doesn't support resource pages at the moment
@itsisu-todo 
Feature: Resource pages can be filtered by cohort
  As a teacher
  I want to only see resource pages for my cohort
  So that I can assign a resource page to my class

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
    And the following resource pages exist:
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

  Scenario: Resource Pages are visible for the control cohort
    Given I login with username: teacher password: teacher
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
    Given I login with username: bteacher password: teacher
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
    Given I login with username: cteacher password: teacher
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
    Given I login with username: dteacher password: teacher
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

