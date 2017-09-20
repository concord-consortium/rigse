Feature: Admin can work with interactives

  In order to work with interactives
  As an admin
  I need to create and manage interactives

  Background:
    Given the database has been seeded
    And I am logged in with the username admin

  Scenario: Admin accesses Materials Collections
    When I am on the home page
    And I follow "Admin"
    And I follow "Interactives"
    Then I should be on the interactives index page
    And I should see "Displaying all 15 interactives"
    And I should see "create interactive"
    And I should see "Export Interactives"

  Scenario: Create Valid Article
    Given I am on the interactives index page
    When I click "create interactive"
    Then I should see "(new) /interactives"
    When I fill in "interactive[name]" with "New Interactive"
    And I fill in "interactive[description]" with "New Description" 
    And I fill in "interactive[url]" with "http://www.google.com"
    And I press "Save"
    Then I should be on the show page for interactive "New Interactive"
    And I should see "Interactive was successfully created."
    And I should see "Run Interactive"

  @javascript
  Scenario: Taging Interactives
    Given the following Admin::tag records exist:
      | scope         | tag      |
      | grade_levels  | gl_K     |
      | subject_areas | sa_Math  |
      | model_types   | mt_Video |
    And I am on the interactives index page
    When I click "create interactive"
    Then I should see "(new) /interactives"
    When I fill in "interactive[name]" with "New Interactive"
    And I fill in "interactive[description]" with "New Description" 
    And I fill in "interactive[url]" with "http://www.google.com"
    And under "Grade Levels" I check "gl_K"
    And under "Subject Areas" I check "sa_Math"
    And under "Model Types" I choose "mt_Video"
    And I press "Save"
    Then I should be on the show page for interactive "New Interactive"
    And I should see "Interactive was successfully created."
    And I should see "Run Interactive"
    And I should see "Model type: mt_Video"
    And I should see "Grade Levels: gl_K"
    And I should see "Subject Areas: sa_Math"

    Scenario: Removing tags from Interactives
      Given I am on the edit page of interactive "Interactive 1"
      Then I should see "11" within #primary
      When under "Grade Levels" I uncheck "11"
      And under "Subject Areas" I uncheck "Biology"
      And I press "Save"
      Then I should not see "11" within #primary
      And I should not see "Biology"

    #@javascript @search
    #Scenario: Admin can see search suggestions
    #  Given I am on the search instructional materials page
    #  When I enter search text "Interactive 1" on the search instructional materials page
    #  Then I should see search suggestions for "Interactive 1" on the search instructional materials page

    #@javascript @search
    #Scenario: Admin can sort search results alphabetically
    #  Given I am on the search instructional materials page
    #  When I search for "Interactive" on the search instructional materials page
    #  And I follow "Alphabetical" in Sort By on the search instructional materials page
    #  Then "Interactive 1" should appear before "Interactive 11"
    #  And "Interactive 11" should appear before "Interactive 2"

    #@javascript @search
    #Scenario: Admin can sort search results for interactive on the basis of creation date
    #  Given I am on the search instructional materials page
    #  When I create interactive "Interactive 1" before "Interactive 2" by date
    #  And I search for "Interactive" on the search instructional materials page
    #  And I follow "Oldest" in Sort By on the search instructional materials page
    #  And I wait 2 seconds      
    #  Then "Interactive 1" should appear before "Interactive 2"
    #  When I follow "Newest" in Sort By on the search instructional materials page
    #  And I wait 2 seconds
    #  Then "Interactive 2" should appear before "Interactive 1"

    @javascript @search
    Scenario: Admin should be able to see grouped search results on the basis of material type
      Given I am on the search instructional materials page
      When I enter search text "Geometry" on the search instructional materials page
      And I uncheck "Sequence"
      And I uncheck "Interactive"
      And I check "Activity"
      And I press "GO"
      And I wait 2 seconds
      Then I should see "Geometry"
      And I should see "Triangle is a great subject"
      And I should see "Triangle is a great material"
      And I should not see "Radioactivity"
      When I enter search text "Radioactivity" on the search instructional materials page
      And I check "Sequence"
      And I uncheck "Activity"
      And I uncheck "Interactive"
      And I press "GO"
      And I wait 2 seconds
      Then I should see "Radioactivity"
      And I should see "Nuclear Energy is a great subject"
      And I should not see "Nuclear Energy is a great material"
      And I should not see "Geometry"
      When I enter search text "Interactive" on the search instructional materials page
      And I uncheck "Sequence"
      And I uncheck "Activity"
      And I check "Interactive"
      And I press "GO"
      And I wait 2 seconds
      Then I should see "Interactive"
      And I should not see "Nuclear Energy is a great subject"
      And I should not see "Nuclear Energy is a great material"
      And I should not see "Geometry"

    #@javascript @search
    #Scenario: User can search Interactives using Subject Areas
    #  Given I am on the search instructional materials page      
    #  When I check "Earth and Space Science" under "Subject Areas" filter
    #  Then I should see "Interactive 1"
    #  And I should see "Interactive 5"
    #  And I should see "Interactive 11"
    #  And I should not see "Interactive 2"
    #  And I should not see "Interactive 15"
    #  When I check "Physics" under "Subject Areas" filter
    #  Then I should see "Interactive 1"
    #  And I should see "Interactive 5"
    #  And I should see "Interactive 11"
    #  And I should see "Interactive 11"
    #  And I should see "Interactive 3"
    #  And I should see "Interactive 9"
    #  And I should not see "Interactive 15"
    #  When I uncheck "Earth and Space Science" under "Subject Areas" filter
    #  And I uncheck "Physics" under "Subject Areas" filter
    #  And I check "Biology" under "Subject Areas" filter
    #  Then I should see "Interactive 7"
    #  And I should see "Interactive 13"
    #  And I should not see "Interactive 5"
    #  And I should not see "Interactive 11"
    #  And I should not see "Interactive 11"
    #  And I should not see "Interactive 3"
    #  And I should not see "Interactive 9"
    #  And I should not see "Interactive 15"
    #  When I uncheck "Biology" under "Subject Areas" filter
    #  And I enter search text "Interactive 15" on the search instructional materials page
    #  Then I should see "Interactive 15"

    #@javascript @search
    #Scenario: User can search Interactives using grade levels
    #  Given I am on the search instructional materials page      
    #  When I check "K-2" under "Grade Levels" filter
    #  Then I should see "Interactive 1"
    #  And I should see "Interactive 2"
    #  And I should see "Interactive 3"
    #  And I should see "Interactive 4"
    #  And I should not see "Interactive 5"
    #  And I should not see "Interactive 15"
    #  When I check "3-4" under "Grade Levels" filter
    #  Then I should see "Interactive 1"
    #  And I should see "Interactive 2"
    #  And I should see "Interactive 3"
    #  And I should see "Interactive 4"
    #  And I should see "Interactive 5"
    #  And I should see "Interactive 6"
    #  And I should not see "Interactive 15"
    #  When I uncheck "K-2" under "Grade Levels" filter
    #  When I uncheck "3-4" under "Grade Levels" filter
    #  When I check "5-6" under "Grade Levels" filter
    #  And I should see "Interactive 1"
    #  And I should see "Interactive 7"
    #  And I should see "Interactive 8"
    #  And I should not see "Interactive 2"
    #  And I should not see "Interactive 3"
    #  And I should not see "Interactive 4"
    #  And I should not see "Interactive 5"
    #  And I should not see "Interactive 6"
    #  And I should not see "Interactive 15"
    #  When I uncheck "5-6" under "Grade Levels" filter
    #  And I enter search text "Interactive 15" on the search instructional materials page
    #  And I should see "Interactive 15"

    #@javascript @search
    #Scenario: User can search Interactives using grade levels and subject areas
    #  Given I am on the search instructional materials page
    #  When I check "3-4" under "Grade Levels" filter
    #  And I check "Earth and Space Science" under "Subject Areas" filter
    #  Then I should see "Interactive 1"
    #  And I should see "Interactive 5"
    #  And I should not see "Interactive 11"
    #  And I should not see "Interactive 6"

    #@javascript @search
    #Scenario: User can search Interactives using model types
    #  Given I am on the search instructional materials page      
    #  When I select "Molecular Workbench" under "Model Types" filter
    #  Then I should see "Interactive 1"
    #  And I should see "Interactive 7"
    #  And I should see "Interactive 13"
    #  And I should not see "Interactive 15"
    #  When I select "Evolution Readiness" under "Model Types" filter      
    #  Then I should see "Interactive 14"
    #  And I should see "Interactive 2"
    #  And I should see "Interactive 8"
    #  And I should not see "Interactive 15"
