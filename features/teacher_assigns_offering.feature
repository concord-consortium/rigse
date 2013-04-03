Feature: Teacher can assign an offering to a class
  So my class can perform a task
  As a teacher
  I want to assign offerings to a class

  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded

  Scenario: Teacher can assign an investigation to a class
    Given the following simple investigations exist:
      | name               | user    |
      | A A Test Investigation | teacher |
    And the investigation "A A Test Investigation" is assigned to the class "My Class"
    Then the investigation named "A A Test Investigation" should have "offerings_count" equal to "1"

  Scenario: Teacher can assign a resource page to a class
    Given the following resource pages exist:
      | name               | user    |
      | Test Resource Page | teacher |
    And the resource page "Test Resource Page" is assigned to the class "My Class"
    Then the resource page named "Test Resource Page" should have "offerings_count" equal to "1"

  Scenario: Teacher can assign an Activity to a class
    Given the following activities exist:
      | name          | user    |
      | Test Activity | teacher |
    And the activity "Test Activity" is assigned to the class "My Class"
    Then the activity named "Test Activity" should have "offerings_count" equal to "1"

  @javascript
  Scenario: All potential offerings are visible
    Given the following simple investigations exist:
      | name               | user    |
      | A A Test Investigation | teacher |
    And the investigation "A A Test Investigation" is published
    And the following resource pages exist:
      | name               | user    |
      | Test Resource Page | teacher |
    And the following external activity exists:
      | name        | user    |
      | My Activity | teacher |
    And I am logged in with the username teacher
    And I am on the class page for "My Class"
    Then I should see "Investigation: A A Test Investigation"
    Then I should see "Resource Page: Test Resource Page"
    Then I should see "External Activity: My Activity"

  # default class is only used by SPARKS and they are not planning to continuing using the portal
  @pending
  @javascript
  Scenario: Offerings from the default class show learner data in the default class
    Given the default class is created
    And the student "student" belongs to class "My Class"
    And the following external activity exists:
      | name        | user    | url    |
      | My Activity | teacher | /about |
    When I login as an admin
    And I am on the class page for "Default Class"
    And I assign the external activity "My Activity" to the class "Default Class"
    Then the external activity offering "My Activity" in the class "Default Class" should be a default offering
    And I am logged in with the username teacher
    When I am on the class page for "My Class"
    And I assign the external activity "My Activity" to the class "My Class"
    Then the external activity offering "My Activity" in the class "My Class" should not be a default offering
    And the external activity named "My Activity" should have "offerings_count" equal to "2"
    And I am logged in with the username student
    And I am on the class page for "My Class"
    And I run the activity
    Then I should be on the about page
    And I login as an admin
    And I am on the class page for "Default Class"
    Then I should see "My Activity"
    And I should see "John Nash"
    And the learner count for the external activity "My Activity" in the class "Default Class" should be "1"

  # default class is only used by SPARKS and they are not planning to continuing using the portal
  @pending
  @javascript
  Scenario: Runnables with offerings in regular classes can not be assigned to the default class
    Given the default class is created

    And the following external activity exists:
      | name        | user    |
      | My Activity | teacher |
    And I am logged in with the username teacher
    And I am on the class page for "My Class"
    And I assign the external activity "My Activity" to the class "My Class"
    Then the external activity offering "My Activity" in the class "My Class" should not be a default offering
    And the external activity named "My Activity" should have "offerings_count" equal to "1"
    When I login as an admin
    And am on the class page for "Default Class"
    And I try to assign the external activity "My Activity" to the class "Default Class"
    And the external activity named "My Activity" should have "offerings_count" equal to "1"
    And the class "Default Class" should not have any offerings
