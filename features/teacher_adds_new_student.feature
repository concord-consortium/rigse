Feature: Teacher adds a new student
In order to assign students to the class
the teacher
should be able to add a new student

	Background:
			Given The default project and jnlp resources exist using factories
			And the following students exist:
			  | login      | password   | first_name  | last_name  |
			  | student    | student    | Alfred      | Robert     |
			  
			And the following teachers exist:
			  | login    | password   | first_name | last_name  |
			  | teacher  | teacher    | John       | Nash       |
			And  the teachers "teacher" are in a school named "VJTI"  
			And the following classes exist:
			      | name       | teacher | semester |
			      | My Class   | teacher | Fall     |
			      | My Class 2 | teacher | Fall     |
			And the classes "My Class,My Class 2" are in a school named "VJTI"      
		@javascript	
		Scenario: Teacher can add a registered user
			Given the student "student" belongs to class "My Class 2"
			And I login with username: teacher password: teacher
			And I am on "Student Roster" page for "My Class"
			When I press "Add New Student"
			And I should see "Student Name"
			And I select "Robert, Alfred ( student )" from the html dropdown "student_id_selector"
			And I should see "Robert, Alfred"
			And I press "Add" inside element with selector "#student_add_dropdown"
			And I should see "Robert, Alfred"
			And I follow "Cancel"
			Then I should see "Robert, Alfred"
		@javascript	
		Scenario: Teacher can add an unregistered user
			Given the student "student" belongs to class "My Class"
			And the student "student" belongs to class "My Class 2"
			And I login with username: teacher password: teacher
			And I am on "Student Roster" page for "My Class"
			When I press "Add New Student"
			And I follow "Add a student who is not registered"
			Then I should see "Adding a New Student"	
			