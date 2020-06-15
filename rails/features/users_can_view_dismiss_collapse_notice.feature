Feature: Users can view notices created by project staff

  As a user
  I should be able to view and dismiss notices created by the project staff
  In order to be notified about updates or important information

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And a notice for all roles "Notice for all users"
    
    
  Scenario: Member roles should see notices
    When I am logged in with the username teacher
    And am on getting started page
    Then I should see "Notice for all users"
    
    
  Scenario: Admin roles should see notices
    And I am logged in with the username admin
    And am on the my home page
    Then I should see "Notice for all users"
    
    
  Scenario: Author roles should see notices
    And I am logged in with the username author
    And am on the my home page
    Then I should see "Notice for all users"
    
    
  Scenario: Manager roles should see notices
    And I am logged in with the username manager
    And am on the my home page
    Then I should see "Notice for all users"
    
    
  Scenario: Researcher roles should see notices
    And I am logged in with the username researcher
    And am on the my home page
    Then I should see "Notice for all users"
    
    
  Scenario: Students should not see notices
    And I am logged in with the username student
    And am on my classes page
    Then I should not see "Notice for all users"
    
    
  @dialog
  @javascript
  Scenario: Users can dismiss a notice without affecting other users
    When I am logged in with the username manager
    And am on the my home page
    And I follow "x"
    And accept the dialog
    And I wait 2 seconds
    And I should not see "Notice for all users"
    # Notice should not be visible on revisiting the home page
    And am on the my home page
    Then I should not see "Notice for all users"
    # Notice should be visible for other users
    And I login as an admin
    And am on the my home page
    And I should see "Notice for all users"
    
    
  @javascript
  Scenario: Users can collapse and expand notices
    When I am logged in with the username manager
    And am on the my home page
    And I follow "Hide Notices"
    And I should wait 2 seconds
    Then I should see "Show Notices"
    When I follow "Show Notices"
    And I should wait 2 seconds
    Then I should see "Hide Notices"

  # This test was randomly failing on Travis so it is marked pending for the time being
  @pending @javascript
  Scenario: Notice expand-collapse state should be maintained across sessions
    When I am logged in with the username manager
    And am on the my home page
    And I follow "Hide Notices"
    And I should wait 2 seconds
    Then I should see "Show Notices"
    When I log out
    And I am logged in with the username manager
    And am on the my home page
    Then I should see "Show Notices"
    When I follow "Show Notices"
    And I should wait 2 seconds
    Then I should see "Hide Notices"
    When I log out
    And I am logged in with the username manager
    And am on the my home page
    Then I should see "Hide Notices"
    
    
