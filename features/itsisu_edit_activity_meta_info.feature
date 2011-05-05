Feature: Activity meta information can be edited by an admin
  So that users can see activities in bins
  As a admin
  I want to edit the activity meta information

  Background:
    Given The default project and jnlp resources exist using factories
    Given The theme is "itsisu"
    Given the configuration setting for "unique_activity_names" is "true"
    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |

    And the following activities exist:
      | name                       | user          | publication_status | is_exemplar | grade_level_list  | subject_area_list | unit_list |
      | my_published_activity      | teacher       | published          | false       | Middle School     | Physics           | Sound     |
      | my_published_activity_b    | teacher       | published          | false       | High School       | Chemistry         | Crystals  |
      | exemplar_activity          | teacher       | published          | true        | Middle School     | Physics           | Sound     |

    And the following activities exist:
      | name                       | user          | publication_status | is_exemplar |
      | my_untagged_activity       | teacher       | published          | false       |


  Scenario: admin can update activity meta information
    Given I login as an admin
    And I am on the template edit page for "my_published_activity"
    # verify it starts out in the original state
    Then the "activity_grade_level_list" field should have "Middle School" selected
    Then the "activity_subject_area_list" field should have "Physics" selected
    Then the "activity_unit_list" field should have "Sound" selected

    # do stuff here
    When I select "High School" from "activity_grade_level_list"
    When I select "Chemistry" from "activity_subject_area_list"
    When I select "Crystals" from "activity_unit_list"
    And I click "#activity_submit"
    And I follow "edit"

    # verify stuff here
    Then the "activity_grade_level_list" field should have "High School" selected
    Then the "activity_subject_area_list" field should have "Chemistry" selected
    Then the "activity_unit_list" field should have "Crystals" selected

  Scenario: admin makes an activity an exemplar
    Given I login as an admin
    When I am on the activities page
    Then I should not see "my_untagged_activity" within "#2middleschoolphysics"
    When I am on the template edit page for "my_untagged_activity"
    When I select "Middle School" from "activity_grade_level_list"
    When I select "Physics" from "activity_subject_area_list"
    When I select "Crystals" from "activity_unit_list"
    When I check "activity_is_exemplar"
    And I click "#activity_submit"
    When I am on the activities page
    Then I should see "my_untagged_activity" within "#2middleschoolphysics"
