Feature: External Activities can support a REST publishing api
  Background:
    Given an external activity named "Fun Stuff" with the definition
      """
      {
        "name": "Cool Activity",
        "url": "http://activity.com/activity/1",
        "launch_url": "http://activity.com/activity/1/sessions/",
        "description": "This activity does fun stuff.",
        "sections": [
          {
            "name": "Cool Activity Section 1",
            "pages": [
              {
                "name": "Cool Activity Page 1",
                "elements": [
                  {
                    "type": "open_response",
                    "id": "1234567",
                    "prompt": "Do you like this activity?"
                  },
                  {
                    "type": "multiple_choice",
                    "id": "456789",
                    "prompt": "What color is the sky?",
                    "allow_multiple_selection": false,
                    "choices": [
                      {
                        "id": "97",
                        "content": "red"
                      },
                      {
                        "id": "98",
                        "content": "blue",
                        "correct": true
                      },
                      {
                        "id": "99",
                        "content": "green"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      """
    And a modified version of the external activity named "Fun Stuff" with the definition
      """
      {
        "name": "Cool Activity",
        "url": "http://activity.com/activity/1",
        "launch_url": "http://activity.com/activity/1/sessions/",
        "sections": [
          {
            "name": "Cool Activity Section 1",
            "pages": [
              {
                "name": "Cool Activity Page 1",
                "elements": [
                  {
                    "type": "open_response",
                    "id": "1234568",
                    "prompt": "Why do you like/dislike this activity?"
                  },
                  {
                    "type": "multiple_choice",
                    "id": "456789",
                    "prompt": "What color is the sky?",
                    "allow_multiple_selection": false,
                    "choices": [
                      {
                        "id": "97",
                        "content": "red"
                      },
                      {
                        "id": "98",
                        "content": "blue",
                        "correct": true
                      },
                      {
                        "id": "99",
                        "content": "greenish-green"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      """

  @mechanize
  Scenario: External REST activity is published the first time
    When the external runtime publishes the activity "Fun Stuff"
    Then the portal should respond with a "201" status and location
    And the portal should create an external activity with the following attributes:
      | name            | Cool Activity |
      | url             | http://activity.com/activity/1 |
      | launch_url | http://activity.com/activity/1/sessions/ |
      | description     | This activity does fun stuff. |
    And the external activity should have a template
    And the portal should create an activity with the following attributes:
      | name            | Cool Activity |
    And the portal should create a section with the following attributes:
      | name            | Cool Activity Section 1 |
    And the portal should create a page with the following attributes:
      | name            | Cool Activity Page 1 |
    And the portal should create an open response with the following attributes:
      | prompt          | Do you like this activity? |
      | external_id     | 1234567 |
    And the portal should create a multiple choice with the following attributes:
      | prompt                   | What color is the sky? |
      | allow_multiple_selection | false |
      | external_id              | 456789 |
      | choices                  | [{"external_id": "97", "choice": "red"},{"external_id": "98", "choice": "blue", "is_correct": "true"},{"external_id": "99", "choice": "green"}] |

  @mechanize
  Scenario: External REST activity is published the second time
    Given the external runtime published the activity "Fun Stuff" before
    When the external runtime publishes the activity "Fun Stuff" again
    Then the published activity "Fun Stuff" should be correctly modified by the API

