Feature: External Activities can support a REST api
  Background:
    Given the following external REST activity:
      | name        | Cool Thing |
      | url         | http://activities.com/activity/1 |
    And "activities.com/activity/1" handles a GET with query:
      | domain            | http://www.example.com/      |
      | domain_uid        | domain_uid of 'student'      |
      | externalId        | 999                          |
      | logging           | false                        |
      | returnUrl         | site_url/dataservice/external_activity_data/key |
      | class_info_url    | class_info_url of 'My Class' |
      | context_id        | class_hash of 'My Class'     |
      | platform_id       | site_url                     |
      | platform_user_id  | domain_uid of 'student'      |
      | resource_link_id  | offering.id                  |
    And "activities.com/activity/1" GET responds with
      """
      HTTP/1.1 200 OK
      Content-Type: text/plain

      Super Cool Activity here.
      """
    And "imageshack.com/images/1.png" GET responds with
      """
      HTTP/1.1 200 OK
      Content-Type: image/png

      .PNG fake content here.
      """

  @mechanize
  Scenario: External REST activity is run the first time
    When a student first runs the external activity "Cool Thing"
    Then the browser should send a GET to "activities.com/activity/1"

  @mechanize
  Scenario: External REST activity is run the second time
    Given the student ran the external REST activity "Cool Thing" before
    When the student runs the external activity "Cool Thing" again
    Then the browser should send a GET to "activities.com/activity/1"

  @mechanize
  Scenario: External REST activity sends data back to the portal
    Given the student ran the external REST activity "Cool Thing" before
    When the browser returns the following data to the portal
      """
      [
        { "type": "open_response",
          "question_id": "1234567",
          "answer": "I like this activity"
        },
        { "type": "multiple_choice",
          "question_id": "456789",
          "answer_ids": ["98"],
          "answer_texts": ["blue"]
        },
        { "type": "image_question",
          "question_id": "1970",
          "answer": "This is my image question answer",
          "image_url": "http://imageshack.com/images/1.png"
        }
      ]
      """
    Then the portal should create an open response saveable with the answer "I like this activity"
    And the portal should create an image question saveable with the answer "This is my image question answer"
    And the portal should create a multiple choice saveable with the answer "blue"
    And the student's progress bars should be updated
