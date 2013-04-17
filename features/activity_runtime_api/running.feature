Feature: External Activities can support a REST api
  Background:
    Given the following external REST activity:
      | name             | "Cool Thing" |
      | rest_create_url  | "http://activity.example.com/activity/1/sessions/" |
    And "activity.example.com/activity/1/sessions/" handles a POST and responds with
      """
      HTTP/1.1 201 Created
      Location: http://example.com/activity/1/sessions/1
      Content-Type: application/json

      {
      	"id": 1
      }
      """
    And "activity.example.com/activity/1/sessions/1" handles a GET and responds with
      """
      HTTP/1.1 200 OK
      Content-Type: text/plain

      Super Cool Activity here.
      """

  Scenario: External REST activity is run the first time
    When a student first runs the external activity "Cool Thing"
    Then the portal should send a POST to "activity.example.com/activity/1/sessions/"
    And the browser should send a GET to "activity.example.com/activity/1/sessions/1"

  Scenario: External REST activity is run the second time
    Given a student has already run the external REST activity "Cool Thing" before
    When a student first runs the external activity "Cool Thing"
    Then the portal should not send a POST to "activity.example.com/activity/1/sessions/"
    And the browser should send a GET to "activity.example.com/activity/1/sessions/1"
