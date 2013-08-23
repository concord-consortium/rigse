Feature: External material providers can send back responses for sequences
  Background:
    Given the following external sequence:
        | name             | Cool Thing |
        | url              | http://materials.com/sequences/1 |
        | launch_url  | http://materials.com/sequences/1/sessions/ |
    And "materials.com/sequences/1/sessions/" handles a GET with query:
      | domain     | http://www.example.com/  |
      | externalId | 999                      |
      | returnUrl  | http://www.example.com/dataservice/external_activity_data/888 |
    And "imageshack.com/images/1.png" GET responds with
      """
      HTTP/1.1 200 OK
      Content-Type: image/png

      .PNG fake content here.
      """

  @mechanize
  Scenario: External material provider sends data back to the portal about a sequence
    Given the student ran the external sequence "Cool Thing" before
    When the material provider returns the following data to the portal
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
          "image_url": "imageshack.com/images/1.png"
        }
      ]
      """
    Then the portal should create an open response saveable with the answer "I like this activity"
    And the portal should create an image question saveable with the answer "This is my image question answer"
    And the portal should create a multiple choice saveable with the answer "blue"
    And the student's progress bars should be updated