Feature: Teacher can deactivate materials from a class
  So my class can move on to other things
  As a teacher
  I want to hide materials from a class

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher

  Scenario: Teacher deactives a material
    When I am on the class edit page for "My Class"
    And I uncheck "Radioactivity"
    And I press "Save"
    And I am logged in with the username student
    And I am on my home page
    Then I should not see "Radioactivity"
