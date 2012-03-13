Feature: Investigations can be viewed by guests
  So we can showcase our investigations to non-members
  As the anonymous user
  I want to view the investigations list

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |

    And the following empty investigations exist:
        | name                    | user    | offerings_count | publication_status |
        | b Investigation         | teacher | 5               | published          |        
        | a Investigation         | teacher | 5               | published          |
        | c Investigation         | teacher | 5               | published          |
        | d Investigation         | teacher | 5               | published          |
        | e Investigation         | teacher | 5               | published          |
        | f Investigation         | teacher | 5               | published          |
        | draft g                 | teacher | 5               | draft              |



  @selenium
  Scenario: Guest can Change the sort order
    When I sort investigations by "name DESC"
    Then There should be 6 investigations displayed
    And  "e Investigation" should appear before "f Investigation"   
    And  "draft" should not be displayed in the investigations list

  @slenium
  Scenario: Guests can't see count, or drafts
    When I am on the investigations page
    Then I should not see the "include_drafts" checkbox in the list filter
    And  I should not see the "include_usage_count" checkbox in the list filter
    When I browse draft investigations
    Then "draft" should not be displayed in the investigations list
    When I show offerings count on the investigations page
    Then "assigned 5 times" should not be displayed in the investigations list