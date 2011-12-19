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
    Then I should see the wysiwyg editor within the "Introduction" section

  @selenium
  Scenario: teacher edits section
    When I login with username: teacher password: teacher
    And I am on the template edit page for "first_activity"    
    And I fill in the first templated activity section with "Hello World"
    And I click ".template_save_button"
    Then I should see "Hello World"
    
  @selenium
  Scenario: teacher previews edited section
    When I login with username: teacher password: teacher
    And I am on the template edit page for "first_activity"    
    And I fill in the first templated activity section with "Hello World"
    And I click ".template_save_button" within the "Introduction" section
    And I click ".template_save_button" within the "Concluding Career STEM Question" section
    And I click "#activity_submit"
    Then I should see "Hello World"

  @selenium
  Scenario: teacher enables section
    When I login with username: teacher password: teacher
    And I am on the template edit page for "first_activity" 
    And I enable the "Materials" section
    Then I should see the wysiwyg editor within the "Materials" section

  @selenium
  Scenario: teacher edits section and tries to save activity
    When I login with username: teacher password: teacher
    And I am on the template edit page for "first_activity" 
    And I fill in the first templated activity section with "Hello World"
    And I click "#activity_submit"
    Then I should see and dismiss an alert with "You need to save open editors first"
