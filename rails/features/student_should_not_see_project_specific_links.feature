Feature: Student cannot see project specific links

  As a student
  I should not see project specific links
  In order to keep project specific links available only to teachers

  Background:
  Given The default settings exist using factories
    And the database has been seeded
    And the default project links exist using factories
    And I am logged in with the username student

  @javascript
  Scenario: Student not in project visits homepage
    When I am on my classes page
    Then I should not see a project link labeled "Foo Project Link"
      And I should not see a project link labeled "Bar Project Link"

  @javascript
  Scenario: Student in project visits homepage
    Given the "student" user is added to the default project
    When I am on my classes page
    Then I should not see a project link labeled "Foo Project Link"
      And I should not see a project link labeled "Bar Project Link"
