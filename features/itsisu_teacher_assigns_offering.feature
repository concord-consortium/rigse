Feature: Teachers assign offerings, ITSISU style using the bin view
  So that students can run activities
  As a teacher
  I want to assign activities from the bin view

  Background:
    Given The default project and jnlp resources exist using factories
    Given The theme is "itsisu"
    And the following teachers exist:
      | login         | password        | first_name | last_name |
      | teacher       | teacher         |            |           |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the following activities exist:
      | name                       | user          | publication_status | is_exemplar | grade_level_list  | subject_area_list | unit_list |
      | my_published_activity      | teacher       | published          | false       | Middle School     | Physics           | Sound     |
      | my_published_activity_b    | teacher       | published          | false       | Middle School     | Chemistry         | Crystals  |
  
  @selenium
  Scenario: teacher assigns activities from the bin view
    When I login with username: teacher password: teacher
    And I follow "My Class"
    And I follow "edit"
    And I check the activity "my_published_activity" in the bin view
    And I press "Save this Class"
    Then I should see "Assigned activities (1)"
    And I should see "my_published_activity"

  @selenium
  Scenario: teacher unassigns an activity not used by a learner from the bin view
    Given the activity "my_published_activity" is assigned to the class "My Class"
    When I login with username: teacher password: teacher
    And I follow "My Class"
    Then I should see "Assigned activities (1)"
    And I should see "my_published_activity"
    When I follow "edit"
    And I uncheck the activity "my_published_activity" in the bin view
    And I press "Save this Class"
    Then I should see "Assigned activities (0)"    
    And I should not see "my_published_activity"

  @selenium
  Scenario: teacher unassigns an activity used by a learner from the bin view
    Given the activity "my_published_activity" is assigned to the class "My Class"
    And a student in "My Class" has run the offering "my_published_activity"
    When I login with username: teacher password: teacher
    And I follow "My Class"
    Then I should see "Assigned activities (1)"
    And I should see "my_published_activity"
    When I follow "edit"
    And I uncheck the activity "my_published_activity" in the bin view
    And I press "Save this Class"
    Then I should see "Assigned activities (1)"    
    Then I should see "my_published_activity"
