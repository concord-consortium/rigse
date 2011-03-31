Feature: Admin configures project settings

  In order to customize a projecy
  As the site administrator
  I want to configure a project's settings

  Background:
    Given The default project and jnlp resources exist using factories


  @selenium
  Scenario: Admin enables default class
    Given the following users exist:
      | login       | password       | roles                 |
      | admin_login | admin_password | admin, member, author |
    And I login with username: admin_login password: admin_password
    And I am on the admin projects page
    Then I should see the sites name
    And I should see "Default Class: disabled"
    When I follow "edit project"
    Then I should see "Enable Default Class"
    When I check "Enable Default Class"
    And I press "Save"
    Then I should see "Default Class: enabled"
