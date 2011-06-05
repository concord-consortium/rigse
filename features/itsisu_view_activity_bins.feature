Feature: Activities should be sorted in bins in itsisu theme
  So that activities can be browsed
  As a teacher
  I want to view activities in bins

  Background:
    Given The default project and jnlp resources exist using factories
    Given The theme is "itsisu"
  
  Scenario: teacher sees their activities on the activities page
    And the following teachers exist:
      | login         | password        | first_name | last_name |
      | itest         | password        |            |           |
      | teacher       | teacher         |            |           |
      | teacher_b     | teacher         | Teacher    | B         |
      | teacher_c     | teacher         | Teacher    | C         |

    And the following activities exist:
        | name                       | user          | publication_status | is_exemplar | grade_level_list  | subject_area_list | unit_list |
        | exemplar_activity          | itest         | published          | true        | Middle School     | Physics           | Sound     |
        | draft_exemplar_activity    | itest         | private            | true        | Middle School     | Physics           | Sound     |
        | my_published_activity      | teacher       | published          | false       | Middle School     | Physics           | Sound     |
        | my_published_activity_b    | teacher       | published          | false       | Middle School     | Chemistry         | Crystals  |
        | my_draft_activity          | teacher       | private            | false       | Middle School     | Physics           | Sound     |
        | other_published_activity   | teacher_b     | published          | false       | Middle School     | Physics           | Sound     |
        | other_published_activity_b | teacher_b     | published          | false       | Middle School     | Chemistry         | Crystals  |
        | other_draft_activity       | teacher_b     | private            | false       | Middle School     | Physics           | Sound     |
        | other_published_activity_c | teacher_c     | published          | false       | Middle School     | Physics           | Sound     |
    When I login with username: teacher password: teacher
    And I am on the activities page
    Then I should see "My Activities"
    And I should see "my_published_activity" within "#5myactivities"
    And I should see "my_published_activity_b" within "#5myactivities"
    And I should see "my_draft_activity (private)" within "#5myactivities"
    And I should see "Other Activities"
    And I should see "Teacher B" within "#5otheractivities"
    And I should see "other_published_activity" within "#5otheractivities"
    And I should see "other_published_activity_b" within "#5otheractivities"
    And I should see "Teacher C" within "#5otheractivities"
    And I should see "other_published_activity_c" within "#5otheractivities"
    And I should not see "other_draft_activity"
    And I should see "Middle School Physics"
    And I should see "exemplar_activity" within "#2middleschoolphysics"
    And I should not see "draft_exemplar_activity"

  Scenario: teacher sees tests for their cohort
    Given the following teachers exist:
      | login         | password        | first_name | last_name |
      | teacher       | teacher         |            |           |
    And the teacher "teacher" is in cohort "itsisu"
    And the following activities exist:
      | name                       | user          | publication_status | is_exemplar | grade_level_list  | subject_area_list | unit_list |
      | exemplar_activity          | itest         | published          | true        | Middle School     | Physics           | Sound     |
    And the following tests exist:
      | name                       | publication_status | grade_level_list  | subject_area_list | unit_list | cohort_list |
      | Pre-Test                   | published          | Middle School     | Physics           | Sound     | itsisu      |
    When I login with username: teacher password: teacher
    And I am on the activities page
    Then I should see "Pre-Test"

  Scenario: teacher without cohort should not see tests for a cohort
    Given the following teachers exist:
      | login         | password        | first_name | last_name |
      | teacher       | teacher         |            |           |
    And the following activities exist:
      | name                       | user          | publication_status | is_exemplar | grade_level_list  | subject_area_list | unit_list |
      | exemplar_activity          | itest         | published          | true        | Middle School     | Physics           | Sound     |
    And the following tests exist:
      | name                       | publication_status | grade_level_list  | subject_area_list | unit_list | cohort_list |
      | Pre-Test                   | published          | Middle School     | Physics           | Sound     | itsisu      |
    When I login with username: teacher password: teacher
    And I am on the activities page
    Then I should not see "Pre-Test"
