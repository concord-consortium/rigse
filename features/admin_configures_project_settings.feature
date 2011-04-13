Feature: Admin configures project settings

  In order to customize a project
  As the site administrator
  I want to configure a project's settings

  Scenario: Admin views project without setting up jnlps
    Given The most basic default project
    And I login as an admin
    And am on the admin projects page
    Then I should see the sites name

  @selenium
  Scenario: Admin edits project without setting up jnlps
    Given The most basic default project
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
