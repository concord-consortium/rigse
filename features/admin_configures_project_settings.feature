Feature: Admin configures project settings

  In order to customize a project
  As the site administrator
  I want to configure a project's settings
  
  Scenario: Admin views project without setting up jnlps
    Given the most basic default project
    And the database has been seeded
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name
    
  @javascript
  Scenario: Admin edits project without setting up jnlps
    Given the most basic default project
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
    Then I should see the button "Save"
    
  @javascript
  Scenario: Admin edits project with jnlps
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
    Then I should see the button "Save"
    
  @javascript
  Scenario: Admin sets jnlp CDN hostname
    Given The default project and jnlp resources exist using factories
    When an admin sets the jnlp CDN hostname to "cdn.example.com"
    Then the installer jnlp should have the CDN hostname "cdn.example.com" in the right places
    And the non installer jnlp codebase should not start with "http://cdn.example.com"
    
  @javascript
  Scenario: Admin enables default class
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name
    And I should see "Default Class: disabled"
    When I follow "edit project"
    Then I should see "Enable Default Class"
    When I check "Enable Default Class"
    And I save the project
    Then I should see "Default Class: enabled"
    
  @javascript
  Scenario: Admin enables grade levels for classes
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And I am logged in with the username teacher
    And I am on the clazz create page
    Then I should not see "Grade Levels:"
    Given I login as an admin
    And am on the admin projects page
    Then I should see "Grade Levels for Classes: disabled"
    When I follow "edit project"
    Then I should see "Enable Grade Levels for Classes"
    When I check "Enable Grade Levels for Classes"
    And I save the project
    Then I should see "Grade Levels for Classes: enabled"
    When I am logged in with the username teacher
    And I am on the clazz create page
    Then I should see "Grade Levels:"
    
  @javascript
  Scenario: Admin modifies css for otml
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name
    When I follow "edit project"
    Then I should see "Custom stylesheet for OTML:"
    When I fill in "admin_project[custom_css]" with ".testing_css_class_here {position:relative; padding:5px;}"
    And I save the project
    Then I should see ".testing_css_class_here"
    
  # OTLabbookButton useBitmap="true"
  # OTLabbookBundle scaleDrawTools="false"
  @javascript
  Scenario: Admin configures bitmap snapshots
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name
    When I follow "edit project"
    Then I should see "Use Bitmaps in Labbook Exclusively:"
    When I check "Use Bitmaps in Labbook Exclusively"
    And I save the project
    Then I should see "Use Bitmaps in Labbook Exclusively: Yes"
    
  Scenario: Admin creates a new project
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    When I create a new project with the description "test project"
    Then I should see "test project"
    
  @javascript
  Scenario: Admin should preview Help page from admin projects page
    Given The default project and jnlp resources exist using factories
    When I login as an admin
    And am on the admin projects page
    And I follow "edit project"
    And I choose "Use custom help page HTML"
    And I fill in "admin_project[custom_help_page_html]" with "Creating Help Page"
    And I save the project
    And am on the admin projects page
    And I press "Preview Custom Help Page"
    Then the newly opened window should have content "Creating Help Page"
    And I close the newly opened window
    When am on the admin projects page
    And I follow "edit project"
    And I choose "Use external help URL"
    And I fill in "admin_project[external_url]" with "www.google.com"
    And I save the project
    And am on the admin projects page
    And I press "Preview External Help URL"
    Then the newly opened window should have content "google"
    And I close the newly opened window
    
  @javascript
  Scenario: Admin edits the home page HTML
    Given the most basic default project
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
    And I fill in "admin_project[home_page_content]" with "Creating Home Page"
    And I save the project
    And I log out
    And am on the my home page
    Then I should see "Creating Home Page"
    
  @javascript
  Scenario: Admin can preview edited home page
    Given the most basic default project
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
    And I fill in "admin_project[home_page_content]" with "Creating Home Page"
    And I save the project
    And I press "Preview Home Page"
    Then the newly opened window should have content "Creating Home Page"
    And the newly opened window should have content "Username"
    And the newly opened window should have content "Password"
    And I close the newly opened window
    
  @javascript
  Scenario: Admin can preview the home page from admin projects page
    Given the most basic default project
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
    And I fill in "admin_project[home_page_content]" with "Creating Home Page"
    And I save the project
    And am on the admin projects page
    And I press "Preview Home Page"
    Then the newly opened window should have content "Creating Home Page"
    And I close the newly opened window
    