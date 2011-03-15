Feature: Investigations can be searched
  So I can find an investigation more efficiently
  As a teacher
  I want to sort the investigations list

  Background:
    Given The default project and jnlp resources exist using factories
    Given The theme is "rites"
    Given the following users exit:
      | login         | password        | roles |
      | author        | author          | author|


    And the following students exist:
      | login         | password        |
      | student       | student         |

    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following investigations exist:
        | name                    | user    | offerings_count | publication_status | 
        | a Investigation         | author  | 5               | published          | 
      

  @selenium
  Scenario: Investigation and resource links are hidden from teachers
    When I login with username: teacher password: teacher
    And  I am on the home page
    Then I should see "RITES"
    And  I should not see "APP_CONFIG"
    And  I should not see "Resources" within "#nav_top"
    And  I should not see "Investigation" within "#nav_top"


  @selenium
  Scenario: Investigation and resource links are hidden from students
    When I login with username: student password: student
    And  I am on the home page
    Then I should see "RITES"
    And  I should not see "APP_CONFIG"
    And  I should not see "Resources" within "#nav_top"
    And  I should not see "Investigation" within "#nav_top"
  
  @selenium
  Scenario: Investigation links are shown to authors
    When I login with username: author password: author
    And  I am on the home page
    Then I should see "RITES"
    And  I should see "Investigation" within "#nav_top"
    And  I should not see "APP_CONFIG"
    And  I should not see "Resources" within "#nav_top"

  @selenium
  Scenario: Resources are hidden from teachers in class assignment
    When I login with username: teacher password: teacher
    And  I am on the class page for "My Class"
    And  I should not see "create resource" within "#resource_pages"

