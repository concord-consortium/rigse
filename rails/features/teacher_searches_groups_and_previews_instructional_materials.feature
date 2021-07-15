Feature: Teacher can search instructional materials grouped by material type, sort and preview them.

  As a teacher
  I want to search instructional materials grouped by material type, sort and preview materials
  In order to find suitable study materials for the class

  Background:
    Given The default settings exist using factories
    And the database has been seeded
    And "differential calculus" has been updated recently
    And "parallel lines" has been updated recently
    And The materials have been indexed
    Given the default settings has include external activities enabled
    And the following external activities exist:
      | name        | user    | url               |
      | Google Home | author  | http://google.com |
    And I am logged in with the username teacher
    And I am on the search instructional materials page

  @javascript @search
  Scenario: Teacher should be on materials preview page to assign materials
    When I search for "differential calculus" on the search instructional materials page
    And I follow the "Assign or Share" link for the activity "differential calculus"
    Then I should see "Select the class(es) you want to assign this resource to below."
    And I should be on the search instructional materials page
    And I should see "Your Classes"
    When I press "Cancel" within the modal
    And I wait 2 seconds
    And I follow activity link "differential calculus" on the search instructional materials page
    Then I should be on the browse materials page for "differential calculus"
    And I should see "differential calculus"


  @javascript @search
  @with_mysql_failures
  Scenario: Teacher can see classes in which materials are assigned on the search page
    When the external activity "differential calculus" is assigned to the class "Physics"
    And I search for "differential calculus" on the search instructional materials page
    Then I should see "Assigned to Physics"
    When the external activity "Fluid Mechanics" is assigned to the class "Physics"
    And I search for "Fluid Mechanics" on the search instructional materials page
    Then I should see "Assigned to Physics"


  # @javascript @search
  # @with_mysql_failures
  # Scenario: Teacher can see number classes to which investigations are assigned on the search page
  #   When the external activity "differential calculus" is assigned to the class "Physics"
  #   And the external activity "differential calculus" is assigned to the class "Geography"
  #   And the external activity "differential calculus" is assigned to the class "Mathematics"
  #   And I search for "differential calculus" on the search instructional materials page
  #   And I wait 2 seconds
  #   Then I should see "Used in 3 classes."
  #   When I am on the browse materials page for "differential calculus"
  #   Then I should see "Used in 3 classes."


  # @javascript @search
  # @with_mysql_failures
  # Scenario: Teacher can see number classes to which activities are assigned on the search page
  #   When the external activity "Geometry" is assigned to the class "Physics"
  #   When the external activity "parallel lines" is assigned to the class "Physics"
  #   And the external activity "parallel lines" is assigned to the class "Geography"
  #   And the external activity "parallel lines" is assigned to the class "Mathematics"
  #   And I search for "parallel lines" on the search instructional materials page
  #   And I wait 2 seconds
  #   Then I should see "Used in 3 classes."
  #   When I am on the browse materials page for "parallel lines"
  #   Then I should see "Used in 3 classes."


  @javascript @search
  Scenario: Anonymous user can preview activity
    When I log out
    And I am on the search instructional materials page
    And I search for "differential calculus" on the search instructional materials page
    Then I should see "differential calculus"
    And I follow activity link "differential calculus" on the search instructional materials page
    Then I should be on the browse materials page for "differential calculus"


  @javascript @search
  Scenario: Teacher can see search suggestions
    When I enter search text "Radioactivity" on the search instructional materials page
    Then I should see search suggestions for "Radioactivity" on the search instructional materials page


  @javascript @search
  @pending
  Scenario: Teacher can sort search results alphabetically
    When I search for "lines" on the search instructional materials page
    And I follow "Alphabetical" in Sort By on the search instructional materials page
    Then "graphs and lines" should appear before "intersecting lines"
    And "intersecting lines" should appear before "parallel lines"
    When I search for "calculus" on the search instructional materials page
    And I follow "Alphabetical" in Sort By on the search instructional materials page
    Then "differential calculus" should appear before "integral calculus"

  @javascript @search
  @with_mysql_failures
  Scenario: Teacher can sort search results for investigations on the basis of creation date
    When I create investigations "differential calculus" before "integral calculus" by date
    And I search for "calculus" on the search instructional materials page
    And I follow "Oldest" in Sort By on the search instructional materials page
    And I wait 2 seconds
    Then "integral calculus" should appear before "differential calculus"
    When I follow "Newest" in Sort By on the search instructional materials page
    And I wait 2 seconds
    Then "differential calculus" should appear before "integral calculus"

  @javascript @search
  @with_mysql_failures
  Scenario: Teacher can sort search results for activities on the basis of creation date
    When I create activities "parallel lines" before "graphs and lines" by date
    And I search for "lines" on the search instructional materials page
    And I follow "Oldest" in Sort By on the search instructional materials page
    And I wait 2 seconds
    Then "graphs and lines" should appear before "parallel lines"
    When I follow "Newest" in Sort By on the search instructional materials page
    And I wait 2 seconds
    Then "parallel lines" should appear before "graphs and lines"


  @javascript @search
  Scenario: Teacher should be able to see grouped search results on the basis of material type
    And I uncheck "Sequence"
    And I check "Activity"
    When I enter search text "Geometry" on the search instructional materials page
    And I press "Go"
    Then I should see "Geometry"
    And I should not see "Radioactivity"
    And I should not see "Geometry sequence"
    And I check "Sequence"
    And I uncheck "Activity"
    And I wait 1 second
    When I enter search text "Radioactivity" on the search instructional materials page
    And I press "Go"
    And I wait 2 seconds
    Then I should see "Radioactivity sequence"
    And I should not see "smaller radioactive activity"
    And I should not see "Geometry"

  @javascript @search
  Scenario: Search results should be paginated
    When I search for "is a great" on the search instructional materials page
    Then the search results should be paginated on the search instructional materials page
