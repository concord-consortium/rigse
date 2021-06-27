Feature: Admin can add, edit and remove notices

  As an admin
  I should be able to add, edit and remove notices
  In order to update my users with important updates or information

  Background:
    Given The default settings exist using factories
    And the database has been seeded
    And I am logged in with the username admin

  @javascript
  Scenario: Admin can add a notice
    When I create a notice "Notice for users"
    And am on the getting started page
    Then I should see "Notice for users"

  @javascript
  Scenario: Admin can edit notices
    Given a notice "Notice for admin"
    And am on the site notices index page
    And the notices have loaded
    When I follow "edit"
    And I fill "Edited notice for users" in the tinyMCE editor with id "notice_html"
    And I press "Update Notice"
    And am on the getting started page
    Then I should see "Edited notice for users"

  @dialog
  @javascript
  Scenario: Admin can remove notices
    Given a notice "Notice for admin"
    And am on the site notices index page
    And the notices have loaded
    When I follow "Delete Notice"
    And accept the dialog
    And am on the my home page
    Then I should not see "Notice for admin"

  @javascript
  Scenario: Admin cannot publish blank notices
    When I create a notice " "
    Then I should see "Notice text is blank"

  @javascript
  Scenario: Admin can cancel notice creation or editing
    Given a notice "Notice for admin"
    When I go to the admin create notice page
    And I follow "Cancel"
    Then I should be on "the site notices index page"
    And the notices have loaded
    When I follow "edit"
    And I follow "Cancel"
    Then I should be on "the site notices index page"

  Scenario: Anonymous users cannot create notice page
    When I am an anonymous user
    And I try to go to the admin create notice page
    Then I should be on "the signin page"

  @javascript
  Scenario: Admin is shown a message if there are no notices
    When I am on the site notices index page
    Then I should see "You have no notices."
