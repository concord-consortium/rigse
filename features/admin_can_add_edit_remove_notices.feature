Feature: Admin can add, edit and remove notices

  As an admin
  I should be able to add, edit and remove notices
  In order to update my users with important updates or information
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following users exist:
      | login            | roles      |
      | student_login    | member     |
      | manager_login    | manager    |
      | author_login     | author     |
      | researcher_login | researcher |
      | admin_login      | admin      |
    And I login as an admin
    And I create a notice "Notice for admin" for the roles "Admin"
    
    
  @javascript
  Scenario: Admin can add a notice
    When I create a notice "Notice for users" for the roles "Admin"
    And am on the my home page
    Then I should see "Notice for users"
    
    
  @javascript
  Scenario: Admin can edit notices
    When I follow "Edit"
    And I fill "Edited notice for users" in the tinyMCE editor with id "notice_html"
    And I press "Update Notice"
    And am on the my home page
    Then I should see "Edited notice for users"
    
    
  @dialog
  @javascript
  Scenario: Admin can remove notices
    When I follow "Delete Notice"
    And accept the dialog
    And am on the my home page
    Then I should not see "Notice for admin"
    
    
  @javascript
  Scenario: Admin cannot publish blank notices or without selecting any roles
    When I create a notice " " for the roles ""
    Then I should see "Notice text is blank"
    And I should see "No role is selected"
    
    
  @javascript
  Scenario: Admin can cancel notice creation or editing
    When I go to the admin create notice page
    And I follow "Cancel"
    Then I should be on "the site notices index page"
    When I follow "Edit"
    And I follow "Cancel"
    Then I should be on "the site notices index page"
    
    
  @javascript
  Scenario: Anonymous users cannot create notice page
    When I am an anonymous user
    And I go to the admin create notice page
    Then I should be on "my home page"
    
    
  @dialog
  @javascript
  Scenario: Admin is shown a message if there are no notices
    When I follow "Delete Notice"
    And accept the dialog
    Then I should see "You have no notices."
    
    