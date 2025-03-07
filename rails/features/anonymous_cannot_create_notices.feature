Feature: Anonymous user cannot add, edit or remove notices

  As an anonymous user
  I should not be able to add, edit and remove notices

  Background:
    Given The default settings exist using factories
    And the database has been seeded

  @javascript
  Scenario: Anonymous users cannot create notice page
    When I try to go to the admin create notice page
    Then I should be on "the signin page"
