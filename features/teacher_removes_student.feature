
Feature: Teacher removes a student
In order to  keep correct students assigned to the class
the teacher
should be able to remove a student

	Background:
		Given The default project and jnlp resources exist using factories
		And the following students exist:
		  | login     | password  |
		  | student   | student   |
		And the following teachers exist:
		  | login    | password   | first_name | last_name  |
		  | teacher  | teacher    | John       | Nash       |
		And  the teachers "teacher" are in a school named "VJTI"  

	    And the following semesters exist:
		      | name     | start_time          | end_time            |
		      | Fall     | 2012-12-01 00:00:00 | 2012-03-01 23:59:59 |
		      | Spring   | 2012-10-10 23:59:59 | 2013-03-31 23:59:59 |
		And the following classes exist:
		      | name     | teacher |semester |
		      | My Class | teacher |  Fall   |
		And the classes "My Class" are in a school named "VJTI"      
		And the student "student" belongs to class "My Class"
	@javascript
	Scenario: Teacher removes a student
		Given I am logged in with the username teacher
		And I am on "Student Roster" page for "My Class"
		And I accept the upcoming javascript confirm box
		When I follow "Remove Student"
		Then I should see "No students registered for this class yet."
    
 