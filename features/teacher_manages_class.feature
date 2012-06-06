Feature: Teacher manages a class

  As a teacher
  I want to manage my classes
  In order to make classes more effective

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password | first_name | last_name |
      | teacher | teacher  | John       |  Nash     |
    And the following classes exist:
      | name       | teacher |
      | My Class 1 | teacher | 
      | My Class 2 | teacher |
      | My Class 3 | teacher |
      | My Class 4 | teacher |
      | My Class 5 | teacher |

  
	


  @javascript 
  Scenario: Teacher deactivates classes
    Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    When I uncheck "My Class 4"
    And I uncheck "My Class 5"
    And I press "Save"
    Then I should not see "My Class 4" within left panel of manage class page
    Then I should not see "My Class 5" within left panel of manage class page    
 
 
  @javascript
  Scenario: Teacher creates a copy of a class
    Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    And I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of My Class 1"
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" inside element with selector ".popup_content"
    Then I should see "Copy of My Class 1"
    
    
 @javascript
  Scenario: Teacher can reorder the class list
    Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    And I move "My Class 3" to the top of the list with id "sortable"
    And I press "Save"    
    Then "My Class 3" should be the first on the list with id "sortable"
    
    
    
   
