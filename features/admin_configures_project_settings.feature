Feature: Admin configures project settings

  In order to customize a project
  As the site administrator
  I want to configure a project's settings

  Scenario: Admin views project without setting up jnlps
    Given the most basic default project
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name

  @selenium
  Scenario: Admin edits project without setting up jnlps
    Given the most basic default project
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
    Then I should see the button "Save"

  @selenium
  Scenario: Admin edits project with jnlps
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    When I follow "edit project"
    Then I should see the button "Save"

  @selenium
  Scenario: Admin sets jnlp CDN hostname
    Given The default project and jnlp resources exist using factories
    When an admin sets the jnlp CDN hostname to "cdn.example.com"
    Then the installer jnlp codebase and wrapped_jnlp should start with "http://cdn.example.com"
    And the non installer jnlp codebase should not start with "http://cdn.example.com"

  @selenium
  Scenario: Admin enables default class
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name
    And I should see "Default Class: disabled"
    When I follow "edit project"
    Then I should see "Enable Default Class"
    When I check "Enable Default Class"
    And I press "Save"
    Then I should see "Default Class: enabled"

  @selenium
  Scenario: Admin enables grade levels for classes
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    When I login with username: teacher password: teacher
    And I am on the clazz create page
    Then I should not see "Grade Levels:"
    Given I login as an admin
    And am on the admin projects page
    Then I should see "Grade Levels for Classes: disabled"
    When I follow "edit project"
    Then I should see "Enable Grade Levels for Classes"
    When I check "Enable Grade Levels for Classes"
    And I press "Save"
    Then I should see "Grade Levels for Classes: enabled"
    When I login with username: teacher password: teacher
    And I am on the clazz create page
    Then I should see "Grade Levels:"

  @selenium
  Scenario: Admin modifies css for otml
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name
    When I follow "edit project"
    Then I should see "Custom stylesheet for OTML:"
    When I fill in "admin_project[custom_css]" with ".testing_css_class_here {position:relative; padding:5px;}"
    And I press "Save"
    Then I should see ".testing_css_class_here"

  # OTLabbookButton useBitmap="true"
  # OTLabbookBundle scaleDrawTools="false"
  @selenium
  Scenario: Admin configures bitmap snapshots
    Given The default project and jnlp resources exist using factories
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name
    When I follow "edit project"
    Then I should see "Use Bitmaps in Labbook Exclusively:"
    When I check "Use Bitmaps in Labbook Exclusively"
    And I press "Save"
    Then I should see "Use Bitmaps in Labbook Exclusively: Yes"


