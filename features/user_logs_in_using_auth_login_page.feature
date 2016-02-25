Feature: User logs in using auth/login page (e.g. coming from an external site)

  As a user
  I want to login
  
  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded

  Scenario: Users with different roles should be able to log in
    When I login with username: teacher password: password using auth/login page
    And I should not see "Invalid login or password."
    When I login with username: student password: password  using auth/login page
    And I should not see "Invalid login or password."

  Scenario: User should see error message if he provides incorrect username or password
    When I login with username: teacher_WRONG password: password using auth/login page
    And I should see "Invalid login or password."
    When I login with username: teacher password: password_WRONG using auth/login page
    And I should see "Invalid login or password."
