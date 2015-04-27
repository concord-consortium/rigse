Feature: User logs in using header login box to use the portal

  As a user
  I want to login
  In order to use the portal
  
  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    
    
  Scenario: Teacher should be logged in
    When I login with username: teacher password: password
    And I should not see "Invalid login or password."
    
    
  Scenario: Student should be logged in
    When I login with username: student password: password
    And I should not see "Invalid login or password."
    
    
  Scenario: Other user with different roles should be logged in
    When I login with username: author password: password
    Then I should not see "Invalid login or password."
    When I login as an admin
    Then I should not see "Invalid login or password."
    When I login with username: manager password: password
    Then I should not see "Invalid login or password."
    
    
  Scenario: Anonymous user should see header login box
    When I am an anonymous user
    And I am on the home page
    Then I should see "Can't log in?" within header login box
