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


  @javascript @search
  Scenario: Teacher should be able to filter the search results on the basis of domains
    When I check "Biological Science"
    Then I should see "Digestive System"


  @javascript @search
  Scenario: Teacher should be able to filter the search results on the basis of grades
    When I check "10-11"
    Then I should see "Digestive System"
    And I should see "Bile Juice"


  @javascript @search
  Scenario: Teacher views all investigations and activities for all grades
    Then I should see "Digestive System"
    And I should see "Bile Juice"


  @javascript @search
  Scenario: Teacher should be able to filter the search results on the basis of probes
    When I check "Temperature"
    And I should see "A Weather Underground"
    And I should see "A heat spontaneously"
    And I should not see "Digestive System"
    And I should not see "Bile Juice"
    And I uncheck "Temperature"
    And I check "UVA Intensity"
    Then I should not see "A Weather Underground"
    And I should not see "A heat spontaneously"
    And I check "Temperature"
    And I should see "A Weather Underground"
    And I should see "A heat spontaneously"


  @javascript @search
  Scenario: Teacher views all investigations and activities with sensors
    When I follow "check all"
    And I uncheck "Sensors Not Necessary"
    Then I should see "A Weather Underground"
    And I should see "A heat spontaneously"
    And I should not see "Digestive System"
    And I should not see "Bile Juice"


  @javascript @search
  Scenario: Teacher views investigations and activities without sensors
    When I check "Sensors Not Necessary"
    Then I should not see "A Weather Underground"
    And I should not see "A heat spontaneously"
    When I uncheck "Sensors Not Necessary"
    And I follow "clear"
    And I should see "A Weather Underground"
    And I should see "A heat spontaneously"
