Feature: Admin switches to a different user

  In order to see the portal as other users do without knowing their passwords
  As an admin
  I want to switch to a different user

  Scenario: Admin switches to student
    Given I login as an admin
    And the following users exist:
     | login     | password  | roles   | first_name | last_name |
     | student   | student   | member  | Joe        | Student   |
    And I switch to "student"
    Then I should see "Welcome Joe Student"
