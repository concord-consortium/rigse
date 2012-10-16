Feature: Admin configures project help page

  In order to customize a project help page
  As the site administrator
  I want to configure  project's settings
  
  Background:
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
  
  @javascript
  Scenario: Admin can add an external URL for the help page
    When I choose "Use external help URL"
    And I fill "external_url_textbox" with "www.google.com"
    And I press "Save"
    And I follow "Help"
    Then the newly opened window should have content "Google"
    And I am on the search instructional materials page
    And I follow "Help"
    Then the newly opened window should have content "Google"
    
  @javascript
  Scenario: Admin can preview the help page if it is an external URL
    When I choose "Use external help URL"
    And I fill "external_url_textbox" with "www.google.com"
    And I press "Preview help external url"
    Then the newly opened window should have content "Google"
    
  @javascript
  Scenario: Admin can add custom HTML for the help page
    When I choose "Use custom help HTML"
    And I fill "custom_help_page_html_textarea" with "Creating Help Page"
    And I press "Save"
    And I follow "Help"
    Then the newly opened window should have content "Creating Help Page"
    And I am on the search instructional materials page
    And I follow "Help"
    Then the newly opened window should have content "Google"
    
  @javascript
  Scenario: Admin can preview the help page if it has added HTML
    When I choose "Use custom help HTML"
    And I fill "custom_help_page_html_textarea" with "Creating Help Page"
    And I press "Preview help custom page"
    Then the newly opened window should have content "Creating Help Page"
    
  @javascript
  Scenario: Admin can preview the help page of unchecked help type
    When I fill "custom_help_page_html_textarea" with "Creating Help Page"
    And I fill "external_url_textbox" with "www.google.com"
    And I choose "Use external help URL"
    And I press "Preview help custom page"
    Then the newly opened window should have content "Creating Help Page"
    
  @javascript
  Scenario: Admin should see messages if text boxes are blank
    When I fill "custom_help_page_html_textarea" with ""
    And I press "Preview help custom page"
    Then I should see "" within the message popup on the admin projects page
    When I fill "external_url_textbox" with ""
    And I press "Preview help custom page"
    Then I should see "" within the message popup on the admin projects page
    