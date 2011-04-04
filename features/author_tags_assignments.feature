Feature: Author tags assignments

  In order to specify active runnables in a class
  As an author
  I want to tag certain runnables as "active"

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |

  @javascript
  Scenario: Tagging External Activities
    When I login with username: teacher password: teacher
    And I am on the new external activity page
    Then I should see "Tags"
    And I should see "active"
    When I check "active_tag"
    And I fill in "external_activity_name" with "My Activity"
    And I fill in "external_activity_description" with "This is an external activity"
    And I fill in "external_activity_url" with "http://localhost"
    And I fill in "external_activity_save_path" with "path/to/save"
    And I press "Save"
    Then the external activity "My Activity" should have been created
    And the external activity "My Activity" should be tagged with "active"

  @javascript
  Scenario: Tagging Investigations
    When I login with username: teacher password: teacher
    And I am on the create investigation page
    Then I should see "Tags"
    And I should see "active"
    When I check "active_tag"
    And I fill in "investigation_name" with "My Investigation"
    And I fill in "description_field" with "This is an investigation"
    And I press "Save"
    Then the investigation "My Investigation" should have been created
    And the investigation "My Investigation" should be tagged with "active"

  @javascript
  Scenario: Tagging Pages
    When I login with username: teacher password: teacher
    And I am on the new page page
    Then I should see "Tags"
    And I should see "active"
    When I check "active_tag"
    And I fill in "page_name" with "My Page"
    And I fill in "page_description" with "This is a page"
    And I press "Save"
    Then the page "My Page" should have been created
    And the page "My Page" should be tagged with "active"

  @javascript
  Scenario: Tagging Activities
    When I login with username: teacher password: teacher
    And I am on the new activity page
    Then I should see "Tags"
    And I should see "active"
    When I check "active_tag"
    And I fill in "activity_name" with "My Activity"
    And I fill in "activity_description" with "This is an activity"
    And I press "Save"
    Then the activity "My Activity" should have been created
    And the activity "My Activity" should be tagged with "active"
