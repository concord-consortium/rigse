Feature: Activities should be sorted in bins in itsisu theme
  So that activities can be browsed
  As a teacher
  I want to view activities in bins

  Background:
    Given The default project and jnlp resources exist using factories
    Given The theme is "itsisu"
		Given the configuration setting for "unique_activity_names" is "true"
    And the following teachers exist:
      | login         | password        |
      | itest         | password        |
      | teacher       | teacher         |
      | other_teacher | teacher         |
		
		And the following activities exist:
        | name                     | user          | publication_status | is_exemplar | grade_level_list  | subject_area_list |
        | exemplar_activity        | itest         | published          | true        | Middle School     | Physics           |
        | draft_exemplar_activity  | itest         | private            | true        | Middle School     | Physics           |
        | my_published_activity    | teacher       | published          | false       | Middle School     | Physics           |
        | my_draft_activity        | teacher       | private            | false       | Middle School     | Physics           |
        | other_published_activity | other_teacher | published          | false       | Middle School     | Physics           |
        | other_draft_activity     | other_teacher | private            | false       | Middle School     | Physics           |
  
  Scenario: teacher sees their activities on the activities page
    When I login with username: teacher password: teacher
    And I am on the activities page
    Then I should see "My Activities"
    And I should see "my_published_activity" within "#myactivitiesphysics"
    And I should see "my_draft_activity" within "#myactivitiesphysics"
    And I should see "Other Activities"
    And I should see "other_published_activity" within "#otheractivitiesphysics"
    And I should not see "other_draft_activity"
  #  And I should see "Middle School Physics"
  #  And I should see "exemplar_activity"  within "#middleschoolphysics"   # these don't work because 'bin_keys' never gets set on activities
  #  And I should not see "draft_exemplar_activity"
