Feature: Admin configures project help page

  In order to customize a project help page
  As the site administrator
  I want to configure  project's settings
  
  Background:
    Given the most basic default project
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
  
  @javascript
  Scenario: Admin can preview the help page if it has added HTML
    When I fill in "admin_project[custom_help_page_html]" with "Creating Help Page"
    And I press "Preview Custom Help Page"
    And I wait 2 seconds
    Then the newly opened window should have content "Creating Help Page"
    And I close the newly opened window
    
  @javascript
  Scenario: Admin can add an external URL for the help page
    When I choose "Use external help URL"
    And I check "Mark this project as active:"
    And I fill in "admin_project[external_url]" with "www.google.com"
    And I press "Save"
    And I follow "edit project"
    And I should see "http://www.google.com" in the input box of external URL for help page on projects page
    And I should wait 2 seconds
    And I follow "Help" within the top navigation bar
    Then the newly opened window should have content "Google"
    And I close the newly opened window
    And I am on the search instructional materials page
    And I follow "Help" within the top navigation bar
    Then the newly opened window should have content "Google"
    And I close the newly opened window
    
  @javascript
  Scenario: Admin can add custom HTML for the help page
    When I choose "Use custom help page HTML"
    And I check "Mark this project as active:"
    And I fill in "admin_project[custom_help_page_html]" with "Creating Help Page"
    And I press "Save"
    And I should wait 2 seconds
    And I follow "Help"
    Then the newly opened window should have content "Creating Help Page"
    And I close the newly opened window
    And I am on the search instructional materials page
    And I follow "Help"
    Then the newly opened window should have content "Creating Help Page"
    And I close the newly opened window
    
  @javascript
  Scenario: Admin can preview the help page if it is an external URL
    When I fill in "admin_project[external_url]" with "www.google.com"
    And I press "Preview External Help URL"
    And I wait 2 seconds
    Then the newly opened window should have content "Google"
    And I close the newly opened window
    
  @javascript
  Scenario: Admin should see errors on saving the project settings if text boxes are blank
    When I fill in "admin_project[custom_help_page_html]" with ""
    And I choose "Use custom help page HTML"
    And I press "Save"
    Then I should see "Custom HTML cannot be blank if selected as the help page." within the message popup on the admin projects page
    When am on the admin projects page
    And I follow "edit project"
    And I fill in "admin_project[external_url]" with ""
    And I choose "Use external help URL"
    And I press "Save"
    Then I should see "Please enter a valid external help URL." within the message popup on the admin projects page
    
  @javascript
  Scenario: Admin should see errors on previewing the the help page if text boxes are blank
    When I fill in "admin_project[custom_help_page_html]" with ""
    And I press "Preview Custom Help Page"
    Then I should see "Please enter some custom help HTML to preview." within the message popup on the admin projects page
    When am on the admin projects page
    And I follow "edit project"
    And I fill in "admin_project[external_url]" with ""
    And I press "Preview External Help URL"
    Then I should see "Please enter a valid external help URL." within the message popup on the admin projects page
    
 @javascript
  Scenario: Admin should be allowed to remove help page link
    When I choose "No help link"
    And I press "Save"
    Then I should see "No Help Page"
    And am on the Project Help Page
    Then I should see "There is no help available for this site."
    And I go to the search instructional materials page
    Then Help link should not appear in the top navigation bar
    