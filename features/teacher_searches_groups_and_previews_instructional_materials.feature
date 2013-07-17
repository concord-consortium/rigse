Feature: Teacher can search instructional materials grouped by material type, sort and preview them.

  As a teacher
  I want to search instructional materials grouped by material type, sort and preview materials
  In order to find suitable study materials for the class
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    Given the default project has include external activities enabled
    And the following external activities exist:
      | name        | user    | url               |
      | Google Home | author  | http://google.com |
    And I login with username: teacher password: password
    And I am on the search instructional materials page


  @javascript
  Scenario: Teacher should be on materials preview page to assign materials
    When I follow the "Assign to a Class" link for the investigation "differential calculus"
    Then I should be on the preview investigation page for the investigation "differential calculus"
    And I should see "differential calculus"
    And I am on the search instructional materials page
    And I should see "Instructional Materials"
    And I follow the "Assign to a Class" link for the activity "differential calculus"
    Then I should be on the preview activity page for the activity "differential calculus"
    And I am on the search instructional materials page
    And I should see "Instructional Materials"
    And I follow investigation link "differential calculus" on the search instructional materials page
    Then I should be on the preview investigation page for the investigation "differential calculus"
    And I should see "differential calculus"
    And I am on the search instructional materials page
    And I should see "Instructional Materials"
    And I follow activity link "differential calculus" on the search instructional materials page
    Then I should be on the preview activity page for the activity "differential calculus"
    And I should see "differential calculus"
    And I am on the search instructional materials page
    When I follow the "Show more details..." link for the investigation "differential calculus"
    Then I should be on the preview investigation page for the investigation "differential calculus"
    And I should see "differential calculus"
    And I am on the search instructional materials page
    And I follow the "Show more details..." link for the activity "differential calculus"
    Then I should be on the preview activity page for the activity "differential calculus"
    And I should see "differential calculus"
    
    
  @javascript
  Scenario: Teacher should be on materials preview page to preview materials
    When I follow the "Preview" link for the investigation "differential calculus"
    Then I should see "As Teacher"
    And I should see "As Student"
    And I am on the search instructional materials page
    And I should see "Instructional Materials"
    And I follow the "Preview" link for the activity "differential calculus"
    Then I should see "As Teacher"
    And I should see "As Student"
    
    
  @javascript
  Scenario: Teacher can see classes in which materials are assigned on the search page
    When the Investigation "differential calculus" is assigned to the class "Physics"
    And I search for "differential calculus" on the search instructional materials page
    Then I should see "(Assigned to Physics)"
    And the Activity "Fluid Mechanics" is assigned to the class "Physics"
    And I search for "Fluid Mechanics" on the search instructional materials page
    Then I should see "(Assigned to Physics)"
    
    
  @javascript
  Scenario: Teacher can see number classes to which investigations are assigned on the search page
    When the Investigation "differential calculus" is assigned to the class "Physics"
    And the Investigation "differential calculus" is assigned to the class "Geography"
    And the Investigation "differential calculus" is assigned to the class "Mathematics"
    And I am on the search instructional materials page
    Then I should see "Used in 3 classes."
    And I am on the the preview investigation page for the investigation "differential calculus"
    Then I should see "Used in 3 classes."
    
    
  @javascript
  Scenario: Teacher can see number classes to which activities are assigned on the search page
    When the Investigation "Geometry" is assigned to the class "Physics"
    When the Activity "parallel lines" is assigned to the class "Physics"
    And the Activity "parallel lines" is assigned to the class "Geography"
    And the Activity "parallel lines" is assigned to the class "Mathematics"
    And I am on the search instructional materials page
    And I search for "parallel lines" on the search instructional materials page
    Then I should see "Used in 4 classes."
    And I am on the the preview activity page for the activity "parallel lines"
    Then I should see "Used in 4 classes."
    
    
  Scenario: Anonymous user can preview investigation
    When I log out
    And I go to the search instructional materials page
    Then I should preview investigation "Geometry" on the search instructional materials page
    
    
  Scenario: Anonymous user can preview activity
    When I log out
    And I go to the search instructional materials page
    Then I should preview activity "differential calculus" on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can see search suggestions
    When I enter search text "Radioactivity" on the search instructional materials page
    Then I should see search suggestions for "Radioactivity" on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can search instructional materials
    When I search for "Venn Diagram" on the search instructional materials page
    Then I should see search results for "Venn Diagram" on the search instructional materials page
    
    
  @javascript
  Scenario: Teacher can sort search results alphabetically
    When I search for "lines" on the search instructional materials page
    And I follow "Alphabetical" in Sort By on the search instructional materials page
    Then "graphs and lines" should appear before "intersecting lines"
    And "intersecting lines" should appear before "parallel lines"
    And I search for "calculus" on the search instructional materials page
    And I follow "Alphabetical" in Sort By on the search instructional materials page
    Then "differential calculus" should appear before "integral calculus"
    
    
  @javascript
  Scenario: Teacher can sort search results for investigations on the basis of creation date
    When I create investigations "differential calculus" before "integral calculus" by date
    And I search for "calculus" on the search instructional materials page
    And I follow "Oldest" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    Then "integral calculus" should appear before "differential calculus"
    And I follow "Newest" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    And "differential calculus" should appear before "integral calculus"
    
    
  @javascript
  Scenario: Teacher can sort search results for activities on the basis of creation date
    When I create activities "parallel lines" before "graphs and lines" by date
    And I search for "lines" on the search instructional materials page
    And I follow "Oldest" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    Then "graphs and lines" should appear before "parallel lines"
    And I follow "Newest" in Sort By on the search instructional materials page
    And I should wait 4 seconds
    Then "parallel lines" should appear before "graphs and lines"
    
    
  @javascript
  Scenario: Teacher can sort search investigations on the basis of popularity
    When the Investigation "differential calculus" is assigned to the class "Physics"
    And the Investigation "differential calculus" is assigned to the class "Geography"
    And the Investigation "differential calculus" is assigned to the class "Mathematics"
    And the Investigation "integral calculus" is assigned to the class "Mathematics"
    And the Investigation "integral calculus" is assigned to the class "Geography"
    And I follow "Popularity" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    And I search for "calculus" on the search instructional materials page
    Then "differential calculus" should appear before "integral calculus"
    
    
  @javascript
  Scenario: Teacher can sort search activities on the basis of popularity
    When the Activity "intersecting lines" is assigned to the class "Physics"
    And the Activity "intersecting lines" is assigned to the class "Geography"
    And the Activity "intersecting lines" is assigned to the class "Mathematics"
    And the Activity "parallel lines" is assigned to the class "Mathematics"
    And the Activity "parallel lines" is assigned to the class "Geography"
    And I follow "Popularity" in Sort By on the search instructional materials page
    And I should wait 2 seconds
    Then "intersecting lines" should appear before "parallel lines"
    
    
  @javascript
  Scenario: Teacher should be able to see grouped search results on the basis of material type
    When I enter search text "Geometry" on the search instructional materials page
    And I uncheck "Sequence"
    And I check "Activity"
    And I press "GO"
    And I should wait 2 seconds
    And I should see "Geometry"
    And I should see "Triangle is a great subject"
    And I should see "Triangle is a great material"
    Then I should not see "Radioactivity"
    When I enter search text "Radioactivity" on the search instructional materials page
    And I check "Sequence"
    And I uncheck "Activity"
    And I press "GO"
    And I should wait 2 seconds
    Then I should see "Radioactivity"
    And I should see "Nuclear Energy is a great subject"
    And I should not see "Nuclear Energy is a great material"
    And I should not see "Geometry"
    
    
  @javascript
  Scenario: Search results should be paginated
    When I search for "is a great" on the search instructional materials page
    Then the search results should be paginated on the search instructional materials page
    
    