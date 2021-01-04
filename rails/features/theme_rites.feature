Feature: Investigations can be searched
  So I can find an investigation more efficiently
  As a teacher
  I want to sort the investigations list

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    Given The theme is "rites"
    And the following empty investigations exist:
        | name                    | user    | offerings_count | publication_status | 
        | a Investigation         | author  | 5               | published          | 
      

  @javascript @wip
  Scenario: Investigation and resource links are hidden from teachers
    When I am logged in with the username teacher
    And  I am on the home page
    Then I should see "RITES"
    And  I should not see "APP_CONFIG"
    And  I should not see "Resources" within "#nav_top"
    And  I should not see "Investigation" within "#nav_top"


  @javascript @wip
  Scenario: Investigation and resource links are hidden from students
    When I am logged in with the username student
    And  I am on the home page
    Then I should see "RITES"
    And  I should not see "APP_CONFIG"
    And  I should not see "Resources" within "#nav_top"
    And  I should not see "Investigation" within "#nav_top"
  
  @javascript @wip
  Scenario: Investigation links are shown to authors
    When I am logged in with the username author
    And  I am on the home page
    Then I should see "RITES"
    And  I should see "Investigation" within "#nav_top"
    And  I should not see "APP_CONFIG"
    And  I should not see "Resources" within "#nav_top"

