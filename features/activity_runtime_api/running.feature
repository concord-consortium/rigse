Feature: External Activities can support a REST api
  Background:
    Given the following external REST activity:
      | name             | Cool Thing |
      | url              | http://activities.com/activity/1 |
      | rest_create_url  | http://activities.com/activity/1/sessions/ |
    And "activities.com/activity/1/sessions/" handles a POST with body
      """
      /returnUrl=http%3A%2F%2Fwww.example.com%2Fdataservice%2Fexternal_activity_data%2F\d+/
      """
    And "activities.com/activity/1/sessions/" POST responds with
      """
      HTTP/1.1 201 Created
      Location: http://activities.com/activity/1/sessions/1
      Content-Type: application/json

      {
      	"id": 1
      }
      """
    And "activities.com/activity/1/sessions/1" handles a GET and responds with
      """
      HTTP/1.1 200 OK
      Content-Type: text/plain

      Super Cool Activity here.
      """

  @mechanize
  Scenario: External REST activity is run the first time
    When a student first runs the external activity "Cool Thing"
    Then the portal should send a POST to "activities.com/activity/1/sessions/"
    And the browser should send a GET to "activities.com/activity/1/sessions/1"

  @mechanize
  Scenario: External REST activity is run the second time
    Given the student ran the external REST activity "Cool Thing" before
    When the student runs the external activity "Cool Thing" again
    Then the portal should not send a POST to "activities.com/activity/1/sessions/"
    And the browser should send a GET to "activities.com/activity/1/sessions/1"
