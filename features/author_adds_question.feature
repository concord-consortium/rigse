Feature: An author adds multiple choice_questions
  As a Investigations author
  I want to add a multiple choice questions to my investigations
  So that I can understand what my students are learning.

  Background:
    Given The default project and jnlp resources exist using mocks

  @selenium
  Scenario: The author adds a multiple choice question to an investigation
    Given the following users exist:
      | login  | password | roles  |
      | author | author   | author |
    Given the following investigation exists:
      | name              | description           | user   |
      | testing fast cars | how fast can cars go? | author |

    And I login with username: author password: author
    When I show the first page of the "testing fast cars" investigation
    Then I should see "Page: 1"
    When I follow "Multiple Choice Question"
    Then I should see "Why do you think ..."
    When I follow xpath "//a[@title='edit multiple choice question']"
    Then I should see "choices"
    And I should see "a"
    And I should see "b"
    And I should see "c"
