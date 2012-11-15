Feature: Teacher can search and assign instructional materials to a class

  As a teacher
  I should be able to preview and assign materials to a class
  In order to provide study materials to the students from the class 
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         | Nash      |
      | albert   | albert   | Albert       | Michael   |
    And the following users exist:
      | login  | password | roles          |
      | author | author   | member, author |
    And the following simple investigations exist:
      | name                   | user   | publication_status | description                                     |
      | Mechanics              | author | published          | Mechanics is a great subject                    |
      | Geometry               | author | published          | Triangle is a great subject                     |
      | differential calculus  | author | published          | differential calculus is a great subject        |
    And the following activities for the above investigations exist:
      | name                        | investigation | user    | publication_status | description                            |
      | Fluid Mechanics             | Mechanics     | author  | published          | Fluid Mechanics is a great material    |
      | Geometry                    | Geometry      | author  | published          | Triangle is a great material           |
    And the following classes exist:
      | name        | teacher    | class_word |
      | Physics     | teacher    | phy        |
      | Mathematics | teacher    | math       |
      | Geography   | teacher    | geo        |
    And I login with username: teacher password: teacher
    
    
  Scenario: Teacher should be able to preview investigation
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I click link "Preview" for investigation "Mechanics" on the materials preview page
    Then I receive a file for download with a filename like "_investigation_"
    
    
  Scenario: Teacher should be able to preview activity
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I click link "Preview" for activity "Fluid Mechanics" on the materials preview page
    Then I receive a file for download with a filename like "_activity_"
    
    
  @wip
  @javascript
  Scenario: Teacher should be able to share investigation
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I click link "Share" for investigation "Mechanics" on the materials preview page
    Then I should see "Social sharing popup"
    
    
  @wip
  @javascript
  Scenario: Teacher should be able to share activity
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I click link "Share" for activity "Fluid Mechanics" on the materials preview page
    Then I should see "Social sharing popup"
    
    
  @javascript
  Scenario: Teacher should be able return on search page
    When I am on the search instructional materials page
    And I follow investigation link "Mechanics" on the search instructional materials page
    And I follow "← return to search"
    Then I should be on the search instructional materials page
    And I follow activity link "Fluid Mechanics" on the search instructional materials page
    And I follow "← return to search"
    Then I should be on the search instructional materials page
    
    
  @wip
  Scenario: Anonymous user can not assign instructional materials to the class
    When I log out
    And I am on the the preview investigation page for the investigation "differential calculus"
    And I follow "Asign Investigation"
    Then I should be on the home page
    
    
  @wip
  @dialog
  @javascript
  Scenario: Teacher can assign investigations to a class
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I follow "Asign Investigation"
    Then I should see "Investigation:" within the assign materials popup on the search page
    And I should see "Geometry" within the assign materials popup on the search page
    When I check "Mathematics"
    And I follow "Save"
    And I should wait 2 seconds
    And accept the dialog
    And I go to the class page for "Mathematics"
    Then I should see "Mechanics"
    
    
  @wip
  @dialog
  @javascript
  Scenario: Teacher can assign activities to a class from the preview investigation page 
    When I am on the the preview investigation page for the investigation "Mechanics"
    And I uncheck "Mechanics" from the investigation preview page
    And I follow "Asign Investigation"
    Then I should see "Activity:" within the assign materials popup on the search page
    And I should see "Fluid Mechanics" within the assign materials popup on the search page
    And "Mechanics" should appear before "Fluid Mechanics"
    When I check "Physics"
    And I follow "Save"
    And I should wait 2 seconds
    And accept the dialog
    And I go to the class page for "Physics"
    Then I should see "Fluid Mechanics"
    
    
  @wip
  @javascript
  Scenario: Teacher can see a message in the popup of assign activity if only investigation is assigned to any class
    When the Investigation "differential calculus" is assigned to the class "Physics"
    And I am on the the preview investigation page for the investigation "differential calculus"
    And I follow "Asign Investigation"
    Then I should see /(Already assigned as part of "differential calculus")/ within the assign materials popup on the search page
    
    
  @wip
  @javascript
  Scenario: Teacher can see a message in the popup if investigation is assigned to any class
    When the Investigation "differential calculus" is assigned to the class "Physics"
    And I am on the the preview investigation page for the investigation "differential calculus"
    And I follow "Asign Investigation"
    And I open the "Assign to a class" link for the investigation "differential calculus"
    Then I should see "Already assigned to the following class(es)" within the assign materials popup on the search page
    And I should see "Physics" within the assign materials popup on the search page
    
    
  @wip
  @javascript
  Scenario: Teacher can see a message in the popup if activity is assigned to any class
    When the Activity "Fluid Mechanics" is assigned to the class "Mathematics"
    And I am on the the preview activity page for the activity "Fluid Mechanics"
    And I follow "Asign Investigation"
    Then I should see "Already assigned to the following class(es)" within the assign materials popup on the search page
    And I should see "Mathematics" within the assign materials popup on the search page
    
    
  @wip
  @javascript
  Scenario: Teacher can see a message in the popup if the investigation is assigned to all the classes
    When I login with username: albert password: albert
    And I am on the the preview investigation page for the investigation "differential calculus"
    And I follow "Asign Investigation"
    And I check "clazz_id[]"
    And I follow "Save"
    And I should wait 2 seconds
    And accept the dialog
    And I am on the the preview investigation page for the investigation "differential calculus"
    And I follow "Asign Investigation
    Then I should see "This material is assigned to all the classes." within the assign materials popup on the search page
    
    
  @wip
  @dialog
  @javascript
  Scenario: Teacher can see a message in the popup if the activity is assigned to all the classes
    When I login with username: albert password: albert
    And I am on the the preview activity page for the activity "Fluid Mechanics"
    And I follow "Asign Investigation"
    And I check "clazz_id[]"
    And I follow "Save"
    And I should wait 2 seconds
    And accept the dialog
    And I am on the the preview activity page for the activity "Fluid Mechanics"
    And I follow "Asign Investigation"
    Then I should see "This material is assigned to all the classes." within the assign materials popup on the search page
    
    
  @wip
  @javascript
  Scenario: Teacher can see a message  if assign to a class popup is opened without creating any class
    When I login with username: albert password: albert
    And I go to the Manage Class Page
    And I uncheck "teacher_clazz[]"
    And I should wait 2 seconds
    And I am on the search instructional materials page
    And I open the "Assign to a class" link for the investigation "differential calculus"
    Then I should see "You don't have any active classes. Once you have created your class(es) you will be able to assign materials to them." within the assign materials popup on the search page
    And I am on the search instructional materials page
    And I open the "Assign to a class" link for the activity "Fluid Mechanics"
    Then I should see "You don't have any active classes. Once you have created your class(es) you will be able to assign materials to them." within the assign materials popup on the search page
    
    