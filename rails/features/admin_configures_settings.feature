Feature: Admin configures settings

  In order to customize the portal
  As the site administrator
  I want to configure settings
  
  Scenario: Admin views settings without setting up jnlps
    Given the most basic default settings
    And the database has been seeded
    And I am logged in with the username admin
    And am on the admin settings page
    Then I should see the sites name
    
  @javascript
  Scenario: Admin edits settings without setting up jnlps
    Given the most basic default settings
    And I am logged in with the username admin
    And am on the admin settings page
    When I follow "edit settings"
    Then I should see the button "Save"
    
  @javascript
  Scenario: Admin edits settings with jnlps
    Given The default settings and jnlp resources exist using factories
    And I am logged in with the username admin
    And am on the admin settings page
    When I follow "edit settings"
    Then I should see the button "Save"

  @javascript
  Scenario: Admin enables default class
    Given The default settings and jnlp resources exist using factories
    And I am logged in with the username admin
    And am on the admin settings page
    Then I should see the sites name
    And I should see "Default Class: disabled"
    When I follow "edit settings"
    Then I should see "ENABLE DEFAULT CLASS"
    When I check "Enable Default Class"
    And I save the settings
    Then I should see "Default Class: enabled"
    
  @javascript
  Scenario: Admin enables grade levels for classes
    Given The default settings and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And I am logged in with the username teacher
    And I am on the clazz create page
    Then I should not see "Grade Levels:"
    Given I login as an admin
    And am on the admin settings page
    Then I should see "Grade Levels for Classes: disabled"
    When I follow "edit settings"
    Then I should see "ENABLE GRADE LEVELS FOR CLASSES"
    When I check "Enable Grade Levels for Classes"
    And I save the settings
    Then I should see "Grade Levels for Classes: enabled"
    When I am logged in with the username teacher
    And I am on the clazz create page
    Then I should see "GRADE LEVELS:"
    
  Scenario: Admin creates a new settings
    Given The default settings and jnlp resources exist using factories
    And I am logged in with the username admin
    And am on the admin settings page
    When I create new settings with the description "test settings"
    Then I should see "test settings"
    
  @javascript
  Scenario: Admin edits the home page HTML
    Given the most basic default settings
    And I am logged in with the username admin
    And am on the admin settings page
    When I follow "edit settings"
    And I fill in "admin_settings[home_page_content]" with "Creating Home Page"
    And I save the settings
    And I log out
    And am on the my home page
    Then I should see "Creating Home Page"
    
  @javascript
  Scenario: Admin can preview edited home page
    Given the most basic default settings
    And I am logged in with the username admin
    And am on the admin settings page
    When I follow "edit settings"
    And I fill in "admin_settings[home_page_content]" with "Creating Home Page"
    And I save the settings
    And I press "Preview Home Page"
    Then the newly opened window should have content "Creating Home Page"
    And I close the newly opened window
