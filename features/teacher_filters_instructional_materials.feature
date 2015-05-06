Feature: Teacher can search and filter instructional materials

  As a teacher
  I should be able to search and filter instructional materials
  In order to find suitable study materials for the class

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And the investigation "Digestive System" with activity "Bile Juice" belongs to domain "Biological Science" and has grade "10-11"
    And the investigation "A Weather Underground" with activity "A heat spontaneously" belongs to probe "Temperature"
    And The materials have been indexed
    And I am logged in with the username teacher
    And I am on the search instructional materials page


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
    When I wait 2 seconds
    Then I should see "Digestive System"
    And I should see "Bile Juice"


  @javascript
  Scenario: Teacher should be able to filter the search results on the basis of probes
    When I check "Temperature"
    And I should wait 2 seconds
    And I should see "A Weather Underground"
    And I should see "A heat spontaneously"
    And I should not see "Digestive System"
    And I should not see "Bile Juice"
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
  Scenario: Teacher views all investigations and activities with sensors
    When I follow "check all"
    And I should wait 2 seconds
    And I uncheck "Sensors Not Necessary"
    And I should wait 2 seconds
    Then I should see "A Weather Underground"
    And I should see "A heat spontaneously"
    And I should not see "Digestive System"
    And I should not see "Bile Juice"


  @javascript
  Scenario: Teacher views investigations and activities without sensors
    When I check "Sensors Not Necessary"
    And I should wait 2 seconds
    Then I should not see "A Weather Underground"
    And I should not see "A heat spontaneously"
    When I uncheck "Sensors Not Necessary"
    And I should wait 2 seconds
    And I follow "clear"
    And I should wait 2 seconds
    And I should see "A Weather Underground"
    And I should see "A heat spontaneously"
