Feature: Teacher manages a class

  As a teacher
  I want to manage my classes
  In order to make classes more effective

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         |  Nash     |
      | teacher1 | teacher  | Steve        |  Ford     |
    And  the teachers "teacher , teacher1" are in a school named "VJTI"  
    And the following classes exist:
      | name       | teacher | class_word |
      | My Class 1 | teacher | C1         |
      | My Class 2 | teacher | C2         |
      | My Class 3 | teacher | C3         |
      | My Class 4 | teacher | C4         |
      | My Class 5 | teacher | C5         |
    And the classes "My Class 1" are in a school named "VJTI"
    And the classes "My Class 2" are in a school named "VJTI"
    And the classes "My Class 3" are in a school named "VJTI"
    And the classes "My Class 4" are in a school named "VJTI"
    And the classes "My Class 5" are in a school named "VJTI"  
	And the following offerings exist in the classes:
      | name                      | class             |
      | Lumped circuit abstraction| My Class 1        |
      | static discipline         | My Class 1        |
      | Non Linear Devices        | My Class 1        |
    And the following students exist:
      | login     | password  |
      | student   | student   |  
    And the student "student" belongs to class "My Class 1"
    And the student "student" belongs to class "My Class 2"
    And the student "student" belongs to class "My Class 3"
    And the student "student" belongs to class "My Class 4"
    And the student "student" belongs to class "My Class 5"  
  
 @javascript
 Scenario: Teacher can follow link to Manage their Class Page 
 	Given I login with username: teacher password: teacher
 	When I go to the Manage Class Page
    Then I should be on Manage Class Page
    
 @javascript
 Scenario: Anonymous user can not manage a class 
 	Given I am an anonymous user
 	When I go to the Manage Class Page 
    Then I should be on "my home page"
    
 @javascript
  Scenario: Teacher can reorder the class list
    Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    And I move "My Class 3" to the top of the list with id "sortable"
    And I press "Save"    
    Then "My Class 3" should be the first on the list with id "sortable"
    And "My Class 3" should be the first class within left panel of manage class page
    
  
  @javascript 
  Scenario: Teacher deactivates classes
    Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    When I uncheck "My Class 4"
    And I uncheck "My Class 5"
    And I press "Save"
    Then I should not see "My Class 4" within left panel of manage class page
    And I should not see "My Class 5" within left panel of manage class page
    
  @javascript 
  Scenario: Student logs in and visits a class page which some other teacher has deactivated
    Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    When I uncheck "My Class 4"
    And I uncheck "My Class 5"
    And I press "Save"
    And I log out 
    And I login with username: student password: student
    Then I should see "My Class 1"
    And I should see "My Class 2"
    And I should see "My Class 3"
    And I should see "My Class 4"
    And I should see "My Class 5"
    
    
  @javascript 
  Scenario: Teacher logs in and visits a class page which some other  teacher has deactivated
    Given Following teacher and class mapping exists:
    	| class_name  | teacher  |
    	| My Class 3  | teacher1 |
    	| My Class 4  | teacher1 |
    	| My Class 5  | teacher1 | 
    And login with username: teacher password: teacher
    And I am on Manage Class Page
    And I uncheck "My Class 4"
    And I uncheck "My Class 5"
    And I press "Save"
    And I log out 
    And I login with username: teacher1 password: teacher
    And I should see "My Class 3"
    And I should see "My Class 4"
    And I should see "My Class 5"    
        
 
 
  @javascript
  Scenario: Teacher creates a copy of a class
    Given Following teacher and class mapping exists:
    	| class_name  | teacher  |
    	| My Class 1  | teacher1 |
    And I login with username: teacher password: teacher
    And I am on Manage Class Page
    And I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of My Class 1"
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" inside element with selector ".popup_content"
    Then I should see "Copy of My Class 1"
    Then "Copy of My Class 1" should be the last on the list with id "sortable"
    And "Copy of My Class 1" should be the last class within left panel of manage class page
    And there should be no student in "Copy of My Class 1"
    And I should see "Steve Ford"
    And I should see "John Nash"
    And I should see "Lumped circuit abstraction"
    And I should see "static discipline"
    And I should see "Non Linear Devices"    
    

@javascript
Scenario: Teacher creates a copy of a class and after that another teacher of original logs in
    Given Following teacher and class mapping exists:
    	| class_name  | teacher  |
    	| My Class 1  | teacher1 |
    	| My Class 2  | teacher1 |
    	| My Class 3  | teacher1 |   
    And I login with username: teacher password: teacher
    And I am on Manage Class Page
    When I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of My Class 1"
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" inside element with selector ".popup_content"
    And I log out
    And login with username: teacher1 password: teacher
    And I am on Manage Class Page
    Then I should see "Copy of My Class 1"
    

    
    
 @javascript
 Scenario: Teacher fills in class name with a blank string while creating a copy class
	Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    And I follow copy class link for first class
    And I fill in "Class Name:" with ""
    And I fill in "Class Word:" with "etrx"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" inside element with selector ".popup_content"
    Then I should see "Name can't be blank"

 @javascript   
 Scenario: Teacher fills in class name with a blank string while creating a copy class
	Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    And I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of My Class 1"
    And I fill in "Class Word:" with ""
    And I fill in "Class Description" with "electronics class"
    And I press "Save" inside element with selector ".popup_content"
    Then I should see "Class word can't be blank"
    
  @javascript  
  Scenario: Teacher fills in class word which has already been taken
	Given I login with username: teacher password: teacher
    And I am on Manage Class Page
    And I follow copy class link for first class
    And I fill in "Class Name:" with "Copy of My Class 1"
    And I fill in "Class Word:" with "C1"
    And I fill in "Class Description" with "electronics class"
    And I press "Save" inside element with selector ".popup_content"
    Then I should see "Class word has already been taken"  