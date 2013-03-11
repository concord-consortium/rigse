@javascript
Feature: Teacher views resource usage

  In order to know how many students have viewed a resource page
  As a teacher, researcher, admin, or manager
  I want to see a count of students who have viewed a resource page

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the following resource pages exist:
      | name          | user    | publication_status |
      | Test Resource | teacher | published          |
    And the following students exist:
      | login   | password |
      | student | student  |
    And the student "student" belongs to class "My Class"
    And I am logged in with the username teacher
    And I am on the class page for "My Class"
    And I assign the resource page "Test Resource" to the class "My Class"

  Scenario: Teacher views resource pages
    When I am on the resource pages page
    Then I should see "Test Resource"
  
  # resource pages appear to be broken with the new student page changes
  # clicking on them takes you to a page like: /users/6249/portal/offerings/857
  # which shows a run button again
  @pending 
  Scenario: Student resource page view increments counter
    When I am on the resource pages page
    And I open the accordion for the resource "Test Resource"
    Then I should see "Viewed by: 0 students"

    When I log out
    And I am logged in with the username student
    And I am on the class page for "My Class"
    Then I should see the run link for "Test Resource"
    When I run the resource page
    Then I should be on the resource page for "Test Resource"
    And I log out
    And I am logged in with the username teacher
    And I am on the resource pages page
    Then I should see "Test Resource"

    When I open the accordion for the resource "Test Resource"
    Then I should see "Viewed by: 1 student"

  Scenario: Teacher resource page views do not increment counter
    When I am on the resource pages page
    And I open the accordion for the resource "Test Resource"
    Then I should see "Viewed by: 0 students"
    When I follow "view" for the resource page "Test Resource"
    Then I should see the "Test Resource" resource page
    And I am on the resource pages page
    And I open the accordion for the resource "Test Resource"
    Then I should see "Viewed by: 0 students"
