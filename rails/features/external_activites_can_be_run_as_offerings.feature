Feature: External Activities can be run as offerings

  As a student
  I want to run an External Activity that has been assigned to me

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded

  @javascript
  Scenario: External Activity offerings are runnable
    When the external activity "My Activity" is assigned to the class "Class_with_no_assignment"
    And I am logged in with the username student
    When I go to my classes page
    And I follow "Class_with_no_assignment" within left panel for class navigation
    And I should see an external run link to "mock_html/test-external-activity.html"
    