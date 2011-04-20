Feature: Activities can be created using the itsisu theme
  So that new activities can be created
  As a teacher
  I want to create a new activity

  Background:
    Given The default project and jnlp resources exist using factories
    Given The theme is "itsisu"
		Given the configuration setting for "unique_activity_names" is "true"
    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
		
		And the following activities exist:
        | name                    | user    | publication_status |
        | first_activity          | teacher | published          |
      

  @selenium
	Scenario: teacher can create an activity with no validation errors
    When I login with username: teacher password: teacher
		And  I am on the activities page
		And I follow "create Activity"
		And I fill in "activity_name" with "my activity"
		And I fill in "activity_description" with "something"
		And I press "activity_submit"
		Then I should see "Activity was successfully created"

	@selenium
	Scenario: teacher gets validation error for duplicate activity name
    When I login with username: teacher password: teacher
		And  I am on the activities page
		And I follow "create Activity"
		And I fill in "activity_name" with "first_activity"
		And I fill in "activity_description" with "something"
		And I press "activity_submit"
		Then I should see "Please pick a unique name"

  Scenario: teacher sees their activities on the activities page
    When I login with username: teacher password: teacher
    And I am on the activities page
    Then I should see "My Activities"
    And I should see "first_activity"