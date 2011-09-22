Feature: An author deletes a page from a section
  As a Investigations author
  I want to delete a page from a section
  So that I can revise my investigation

  Background:
    Given The default project and jnlp resources exist using factories

  @selenium
  Scenario: The author deletes a page from a section
    Given the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    Given the following simple investigations exist:
      | name              | description           | user   |
      | testing fast cars | how fast can cars go? | author |

    And I login with username: author password: author
    And I show the first section of the "testing fast cars" investigation
    Then I should see "Page: testing fast cars"
    When I follow "delete"
    And accept the dialog
    Then I should not see "Page: testing fast cars"
    
