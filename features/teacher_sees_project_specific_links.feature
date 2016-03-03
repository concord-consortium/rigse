Feature: Teacher can see project specific links

  As a teacher
  I should see project specific links
  In order to access custom information per project

  Background:
  Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And the default project links exist using factories
    And I am logged in with the username teacher

  Scenario: Teacher not in project visits homepage
    When I am on getting started page
    Then I should not see a project link labeled "Foo Project Link"
      And I should not see a project link labeled "Bar Project Link"

  Scenario: Teacher in project visits homepage
    Given the "teacher" user is added to the default project
    When I am on getting started page
    Then I should see a project link labeled "Foo Project Link" linking to "http://foo.com"
      And I should see a project link labeled "Bar Project Link" linking to "http://bar.com"

