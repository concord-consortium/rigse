Feature: Sections of activities can be edited using the itsisu theme
  So that activities can be customized
  As a teacher
  I want to edit a section

  Background:
    Given The default project and jnlp resources exist using factories
    And The theme is "itsisu"
    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following templated activities exist:
        | name                    | user    | publication_status |
        | first_activity          | teacher | published          | 

  @selenium
  Scenario: introduction starts out in edit mode
    When I login with username: teacher password: teacher
    And I am on the template edit page for "first_activity"
    Then I should see the wysiwyg editor

  @selenium
  Scenario: teacher edits section
    When I login with username: teacher password: teacher
    And I am on the template edit page for "first_activity"    
    And I fill in the first templated activity section with "Hello World"
    And I click ".template_save_button"
    Then I should see "Hello World"
