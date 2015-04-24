Feature: Teacher creates new portal class

  In order to teach students a lesson
  As a teacher
  I want to create a portal class

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher
    And grade levels for classes is enabled

  Scenario: Class words are stored as lowercase
    Given I am on the clazz create page
    When I fill in "portal_clazz[name]" with "My New Class"
    And I fill in "portal_clazz[class_word]" with "WINSTON"
    And I check "9"
    And I press "Save"
    Then the portal class "My New Class" should have been created
    And the class word for the portal class "My New Class" should be "winston"
