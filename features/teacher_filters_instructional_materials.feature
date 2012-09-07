Feature: Teacher can search and filter instructional materials

  As a teacher
  I should be able to search and filter instructional materials
  In order to find suitable study materials for the class
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         | Nash      |
    And the investigation "Digestive System" with activity "Bile Juice" belongs to domain "Biological Science" and has grade "10-11"
    And the investigation "A Weather Underground" with activity "A heat spontaneously" belongs to probe "Temperature"
    And I login with username: teacher password: teacher
    And I am on the search instructional materials page"
    And the project settings enables use of Grade Span Expectation
    
    
  @javascript
  Scenario: Teacher should be able to filter the search results on the basis of domains
    When I check "Biological Science"
    And I should wait 2 seconds
    Then I should see "Digestive System"
    
    
  @javascript
  Scenario: Teacher should be able to filter the search results on the basis of grades
    When I check "10-11"
    And I should wait 2 seconds
    Then I should see "Digestive System"
    And I should see "Bile Juice"
    
    
  @javascript
  Scenario: Teacher views all investigations and activities for all grades
    When I check "All Grades"
    And I should wait 2 seconds
    Then I should see "Digestive System"
    And I should see "Bile Juice"
    
    
  @javascript
  Scenario: Teacher should be able to filter the search results on the basis of probes
    When I check "Temperature"
    And I should wait 2 seconds
    And I should see "A Weather Underground"
    And I should see "A heat spontaneously"
    And I uncheck "Temperature"
    And I should wait 2 seconds
    And I check "UVA Intensity"
    And I should wait 2 seconds
    Then I should not see "A Weather Underground"
    And I should not see "A heat spontaneously"
    And I check "Temperature"
    And I should wait 2 seconds
    And I should see "A Weather Underground"
    And I should see "A heat spontaneously"
    
    
  @javascript
  Scenario: Teacher views all investigations and activities with probes
    When I follow "all"
    And I should wait 2 seconds
    Then I should see "A Weather Underground"
    And I should see "A heat spontaneously"
    
    
  @javascript
  Scenario: Teacher views  investigations and activities without probes
    When I check "No Probes Required"
    And I should wait 2 seconds
    Then I should not see "A Weather Underground"
    And I should not see "A heat spontaneously"
    And I follow "none"
    And I should wait 2 seconds
    And I should not see "A Weather Underground"
    And I should not see "A heat spontaneously"
    
  Scenario: The project settings for Grade Span Expection is restored
    And the project setting for Grade Span Expectation is restored
    
    