Feature: Teacher can edit their class information
  So that the class information can be accurate

  Background:
    Given The default project and jnlp resources exist using factories

  @selenium
  Scenario: Teacher can follow link to edit their class info
    Given the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    When I login with username: teacher password: teacher
    And go to the class page for "My Class"
    When I follow "edit"
    Then I should be on the class edit page for "My Class"

  Scenario: Anonymous user can not view class
    Given the following classes exist:
      | name      |
      | My Class  |
    And I am an anonymous user
    When I go to the class page for "My Class"
    Then I should be on my home page

  Scenario: Anonymous user cannot not edit class
    Given the following classes exist:
      | name      |
      | My Class  |
    And I am an anonymous user
    When I go to the class edit page for "My Class"
    Then I should be on my home page
