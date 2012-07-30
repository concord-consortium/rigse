Feature: Teacher manages a class

  As a teacher
  I want to manage my classes
  In order to make classes more effective

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | john     | teacher  | John         | Nash      |
      | steve    | teacher  | Steve        | Ford      |
    And the teachers "john, steve" are in a school named "Harvard School"  
    And the following classes exist:
      | name        | teacher | class_word |
      | Physics     | john    | phy        |
      | Chemistry   | john    | chem       |
      | Mathematics | john    | math       |
      | Biology     | john    | bio        |
      | Geography   | john    | geo        |
    And the classes "Physics" are in a school named "Harvard School"
    And the classes "Chemistry" are in a school named "Harvard School"
    And the classes "Mathematics" are in a school named "Harvard School"
    And the classes "Biology" are in a school named "Harvard School"
    And the classes "Geography" are in a school named "Harvard School"  
	And the following offerings exist in the classes:
      | name                      | class     |
      | Lumped circuit abstraction| Physics   |
      | static discipline         | Physics   |
      | Non Linear Devices        | Physics   |
    And the following students exist:
      | login     | password  |
      | student   | student   |  
    And the student "student" belongs to class "Physics"
    And the student "student" belongs to class "Chemistry"
    And the student "student" belongs to class "Mathematics"
    And the student "student" belongs to class "Biology"
    And the student "student" belongs to class "Geography"
    And I am logged in with the username john
    And I go to the Manage Class Page  
  
 @javascript
 Scenario: Teacher should be on Manage their Class Page 
    Then I should be on Manage Class Page
    
 @javascript
 Scenario: Anonymous user can not manage a class 
 	Given I am an anonymous user
 	When I go to the Manage Class Page 
    Then I should be on "my home page"
    
 @javascript
  Scenario: Teacher can reorder the class list
    When I move "Mathematics" to the top of the list with id "sortable"
    And the Manage class list state starts saving
    And the modal for saving manage classes dissappears
    Then "Mathematics" should be the first on the list with id "sortable"
    And "Mathematics" should be the first class within left panel for class navigation
    
  
  @javascript 
  Scenario: Teacher deactivates classes
    When I uncheck "Biology"
    Then I should not see "Biology" within left panel for class navigation
    When I uncheck "Geography"
    And I should not see "Geography" within left panel for class navigation
    
  @javascript 
  Scenario: Student logs in and visits a class page which the teacher has deactivated
    When I uncheck "Biology"
    And I uncheck "Geography"
    And the Manage class list state starts saving
    And the modal for saving manage classes dissappears
    And I log out 
    And I login with username: student
    Then I should see "Physics"
    And I should see "Chemistry"
    And I should see "Mathematics"
    And I should see "Biology"
    And I should see "Geography"
    
    
  @javascript 
  Scenario: Teacher logs in and visits a class page which some other teacher has deactivated
    Given the following teacher and class mapping exists:
    	| class_name  | teacher  |
    	| Mathematics | steve    |
    	| Biology     | steve    |
    	| Geography   | steve    | 
    When I uncheck "Biology"
    And I uncheck "Geography"
    And the Manage class list state starts saving
    And the modal for saving manage classes dissappears
    And I log out 
    And I login with username: steve
    Then I should see "Mathematics"
    And I should see "Biology"
    And I should see "Geography"    
        
 
 
  @javascript
  Scenario: Teacher creates a copy of a class
    Given the following teacher and class mapping exists:
    	| class_name  | teacher  |
    	| Physics     | steve    |
    When I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of Physics"
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    Then I should see "Copy of Physics"
    And "Copy of Physics" should be the last on the list with id "sortable"
    And "Copy of Physics" should be the last class within left panel for class navigation
    And there should be no student in "Copy of Physics"
    And I should see "Steve Ford"
    And I should see "John Nash"
    And I should see "Lumped circuit abstraction"
    And I should see "static discipline"
    And I should see "Non Linear Devices"    
    

  @javascript
  Scenario: Teacher creates a copy of a class to which another teacher belongs and the other teacher logs in.
    Given the following teacher and class mapping exists:
    	| class_name  | teacher  |
    	| Physics     | steve    |
    	| Chemistry   | steve    |
    	| Mathematics | steve    |   
    When I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of Physics"
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    And I log out
    And login with username: steve
    And I am on Manage Class Page
    Then I should see "Copy of Physics"
    

    
    
 @javascript
 Scenario: Teacher fills in class name with a blank string while creating copy of a class
    When I follow copy class link for first class
    And I fill in "Class Name:" with ""
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    Then I should see "Name can't be blank"

 @javascript   
 Scenario: Teacher fills in class word with a blank string while creating copy of a class
    When I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of Physics"
    And I fill in "Class Word:" with ""
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    Then I should see "Class word can't be blank"
    
  @javascript  
  Scenario: Teacher fills in class word which has already been taken
    When I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of Physics"
    And I fill in "Class Word:" with "phy"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" within the popup
    Then I should see "Class word has already been taken"  
    
    
    