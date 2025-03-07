Feature: User logs in using header login box to use the portal

  As a user
  I want to login
  In order to use the portal

  Background:
    Given The default settings exist using factories
    And the database has been seeded

  @javascript
  @wip
  Scenario: Teacher should be logged in
    When I login with username: teacher password: password
    And I should not see "Invalid Login or password."

  @javascript
  Scenario: Student should be logged in
    When I login with username: student password: password
    And I should not see "Invalid Login or password."

  @javascript
  Scenario: Other user with different roles should be logged in
    When I login with username: author password: password
    Then I should not see "Invalid Login or password."
    When I login as an admin
    Then I should not see "Invalid Login or password."
    When I login with username: manager password: password
    Then I should not see "Invalid Login or password."


