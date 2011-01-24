Feature: Teacher generates a report
  So that I can see what the popular activities or resources are
  As a teacher
  I want to generate a report
  
  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the teacher "teacher" has 4 classes
    And there are 20 resource pages
    And I login with username: teacher password: teacher
    
  Scenario: Teacher can see how many times a given resource page has been assigned
    Given all resource pages are assigned to classes
    When I am on the reports for resource pages page
    Then I should see "Resource Reports" within "h2"