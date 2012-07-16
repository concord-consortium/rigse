Feature: Teacher navigates using left pane

  As a teacher
  I want to visit various pages using left pane
  In order to make navigation more effective
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         |  Nash     |
      
    And the following classes exist:
      | name       | teacher | class_word 			|
      | My Class   | teacher | PhysicsClass         |   
   
   And I login with username: teacher password: teacher
 
   @javascript
   Scenario: Teacher sees his/her classes  
  	Then I should see "My Class"  
  	
   
  @javascript
  Scenario: Teacher visits Student Roster page  
  	When I follow "My Class"  
  	And I follow "Student Roster" 
 	Then I should be on "Student Roster" page for "My Class"
 
 @javascript
  Scenario: Teacher visits Class Setup page
  	When I follow "My Class"  
  	And I follow "Class Setup" 
 	Then I should be on the class edit page for "My Class"
 	
 @wip @javascript
  Scenario: Teacher visits Materials page
  	When I follow "My Class"  
  	And I follow "Materials" 
 	Then I should be on Instructional Materials page for "My Class"
 	
# @pending
# Scenario: Teacher visits Full Status page
#  	When I follow "My Class"  
#  	And I follow "Full Status" 
# 	Then I should see Full Status page of "My Class" 




 	
 	
 	
 	
 	 	
 		  