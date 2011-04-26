Feature: Admin authors web models

  As an admin
  I want to author web models

  Background:
    Given The default project and jnlp resources exist using factories

  @selenium
  Scenario: Admin edits web model from listing page
    Given the following web models exist:
      | name     | url                |
      | My Model | http://example.com |
    When I login as an admin
    And I am on the web models page
    Then I should see "My Model"
    When I follow "Edit" for the web model "My Model"
    Then I should see "Editing My Model"
    And I should be on the edit web model page for "My Model"

  @selenium
  Scenario: Admin edits web model from single web model page
    Given the following web models exist:
      | name     | url                |
      | My Model | http://example.com |
    When I login as an admin
    And I am on the web model page for "My Model"
    Then I should see "My Model"
    When I follow "edit"
    Then I should see "Editing My Model"
    And I should be on the edit web model page for "My Model"
