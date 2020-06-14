Feature: Student views report

  In order to know how I did on material
  As an student
  I need to access the student report

  Background:
    Given the most basic default settings
    And the database has been seeded
    And a simple activity with a multiple choice exists
    And the external activity "simple activity" is assigned to the class "Class_with_no_assignment"
    And "http://fake-lara.com/mock_html/test-external-activity25.html" GET responds with
      """
      HTTP/1.1 200 OK
      Content-Type: text/plain

      Super Cool Activity here.
      """

  @lightweight @mechanize
  Scenario: Student sees report link
    When I login with username: davy
    Then I should not see a link to generate a report of my work
    And I should not see "Last run"
    When I run the external activity
    Then the browser should send a GET to "http://fake-lara.com/mock_html/test-external-activity25.html"
    When I visit my classes page
    Then I should see "Last run"
    When I should see a link to generate a report of my work

  @lightweight @mechanize
  Scenario: Student does not see report link if student report is disabled
    When the student report is disabled for the activity "simple activity"
    When I login with username: davy
    And I run the activity
    Then the browser should send a GET to "http://fake-lara.com/mock_html/test-external-activity25.html"
    When I visit my classes page
    Then I should see "Last run"
    And I should not see a link to generate a report of my work

