Feature: User logs in using header login box to use the portal

  As a user
  I want to login
  In order to use the portal
  
  Background:
    Given The default project and jnlp resources exist using factories
      
      
  @javascript
  Scenario: Teacher should be logged in
    When I login with username: teacher password: teacher
    Then I should see "Logged in successfully"
    And I should not see "Forgot your user name or password?"
    
    
  @javascript
  Scenario: Student should be logged in
    When I login with username: student password: student
    Then I should see "Logged in successfully"
    And I should not see "Forgot your user name or password?"
    
    
  @javascript
  Scenario: Other user with different roles should be logged in
    When I login with username: author password: author
    Then I should see "Logged in successfully"
    And I should not see "Forgot your user name or password?"
    When I login with username: admin password: admin
    Then I should see "Logged in successfully"
    And I should not see "Forgot your user name or password?"
    When I login with username: manager password: manager
    Then I should see "Logged in successfully"
    And I should not see "Forgot your user name or password?"
    
    
  Scenario: Anonymous user should see header login box
    When I am an anonymous user
    And I am on the home page
    Then I should see "Forgot login?" within header login box
    
    
  Scenario: Anonymous user should land to the pick signup page
    When I am an anonymous user
    And I am on the home page
    And I follow "Register"
    Then I should be on "the pick signup page"
    
    