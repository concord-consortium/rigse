Feature: User updates account information

  In order to correct mistakes on my account info
  As a registered user
  I want to update my account information

  Background:
    Given The default project and jnlp resources exist using factories

  @selenium
  Scenario Outline: Users can not change their usernames
    Given the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following students exist:
      | login   | password |
      | student | student  |
    When I log out
    And I login with username: <username> password: <password>
    And I am on the user preferences page for the user "<username>"
    Then I should see "User Preferences"
    And I should see "First name"
    But I should not see the xpath "//input[@id='user_login']"
    And I should not see "Username"

    Examples:
      | username | password |
      | student  | student  |
      | teacher  | teacher  |
