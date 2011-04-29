Feature: A guest views the technical requirements

  In order to evaluate the project
  As a guest
  I want to learn what is necessary to run this project

  Scenario: Guest views technical requirements
    Given the most basic default project
    Given I am an anonymous user
    And am on the homepage
    When I follow "Technical Notes and Requirements"
    Then I should be on the requirements page
    And I should see "Technical Notes and Requirements"
    