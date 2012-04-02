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
    And I login with username: teacher password: teacher
    And I am on the class page for "My Class"
    And I assign the resource page "Test Resource" to the class "My Class"

  Scenario: Teacher views resource pages
    When I am on the resource pages page
    Then I should see "Test Resource"
  
  Scenario: Student resource page view increments counter
    When I am on the resource pages page
    And I open the accordion for the resource "Test Resource"
    Then I should see "Viewed by: 0 students"

    When I log out
    And I login with username: student password: student
    And I am on the class page for "My Class"
    Then I should see "View Test Resource"

    When I follow "View Test Resource"
    And I log out
    And I login with username: teacher password: teacher
    And I am on the resource pages page
    Then I should see "Test Resource"

    When I open the accordion for the resource "Test Resource"
    Then I should see "Viewed by: 1 student"

  Scenario: Teacher resource page views do not increment counter
    When I am on the resource pages page
    And I open the accordion for the resource "Test Resource"
    Then I should see "Viewed by: 0 students"

    When I follow "view" for the resource page "Test Resource"
    And I am on the resource pages page
    And I open the accordion for the resource "Test Resource"
    Then I should see "Viewed by: 0 students"
