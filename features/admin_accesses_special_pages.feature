Feature: Admin can access various admin pages

  In order to configure the portal
  As an admin
  I need to access various admin pages
  
  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded

  @enable_gses
  Scenario: Admin access GSEs
    When I login as an admin
    And I am on the home page
    And I follow "Admin"
    Then I should see "GSEs"

  @disable_gses
  Scenario: Admin access GSEs
    When I login as an admin
    And I am on the home page
    And I follow "Admin"
    Then I should not see "GSEs"
