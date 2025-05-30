Feature: Teacher filters instructional materials

  As Teacher
  In order to find materials
  I need to search for them by subject and grade

  Background:
    Given the database has been seeded
    And I am logged in with the username admin

  @javascript @search
  @wip #RAILS-UPGRADE-TODO
  Scenario: Searching Tagged materials
    # the default data includes grade levels and many tags already
    Given the following Admin::tag records exist:
      | scope         | tag       |
      | subject_areas | Science   |
      | model_types   | mt_Video  |

    # Create a first grade math activity:
    And I am on the new material page
    Then I should see "(new) /eresources"
    When I fill in "external_activity[name]" with "My grade 5 Math Activity"
    And I check "external_activity[is_official]"
    And I select "published" from "external_activity[publication_status]"
    And I check "grade_levels_5"
    And I scroll "#subject_areas_math" to the center
    And I check "subject_areas_math"
    And I press "Save"

    # Create a 7th grade Science Activity
    And I am on the new material page
    Then I should see "(new) /eresources"
    When I fill in "external_activity[name]" with "My grade 7 Science Activity"
    And I check "external_activity[is_official]"
    And I select "published" from "external_activity[publication_status]"
    And I check "grade_levels_7"
    And I check "subject_areas_science"
    And I press "Save"

   Given I am on the search instructional materials page
   And I uncheck "Sequence"
   And I check "Math"
   And I wait for the search to be ready
   Then I should see "My grade 5 Math Activity"
   And  I should not see "My grade 7 Science Activity"

   When I check "Science"
   And I uncheck "Math"
   And I wait for the search to be ready

   Then I should see "My grade 7 Science Activity"
   And I should not see "My grade 5 Math Activity"

   When I uncheck "Math"
   And I uncheck "Science"
   And I check "grade_level_7-8"
   And I wait for the search to be ready

   Then I should not see "My grade 5 Math Activity"
   And I should see "My grade 7 Science Activity"

   When I uncheck "grade_level_7-8"
   And I check "grade_level_5-6"
   And I wait for the search to be ready

   Then I should see "My grade 5 Math Activity"
   And I should not see "My grade 7 Science Activity"

  @javascript @search
  @wip #RAILS-UPGRADE-TODO
  Scenario: Searching Materials tagged with Sensors
    Given the following Admin::tag records exist:
      | scope         | tag         |
      | sensors       | Temperature |
      | sensors       | Force       |
      | sensors       | Motion      |

    # Create a temperature sensor activity:
    And I am on the new material page
    Then I should see "(new) /eresources"
    When I fill in "external_activity[name]" with "My Temperature Sensor Activity"
    And I check "external_activity[is_official]"
    And I select "published" from "external_activity[publication_status]"
    And under "Sensors" I check "Temperature"
    And I press "Save"

    # Create a force sensor activity:
    And I am on the new material page
    Then I should see "(new) /eresources"
    When I fill in "external_activity[name]" with "My Force Sensor Activity"
    And I check "external_activity[is_official]"
    And I select "published" from "external_activity[publication_status]"
    And under "Sensors" I check "Force"
    And I press "Save"

    # Create an activity with no sensors:
    And I am on the new material page
    Then I should see "(new) /eresources"
    When I fill in "external_activity[name]" with "My No Sensor Activity"
    And I check "external_activity[is_official]"
    And I select "published" from "external_activity[publication_status]"
    And I press "Save"

    Given I am on the search instructional materials page
    And I uncheck "Sequence"
     And I check "Temperature"
     And I wait for the search to be ready
     Then I should see "My Temperature Sensor Activity"
     And I should not see "My Force Sensor Activity"
     And I should not see "My No Sensor Activity"

     When I check "Force"
     And I wait for the search to be ready
     Then I should see "My Temperature Sensor Activity"
     And I should see "My Force Sensor Activity"
     And I should not see "My No Sensor Activity"

     When I uncheck "Temperature"
     And I uncheck "Force"
     And I check "Sensors not necessary"
     And I wait for the search to be ready
     Then I should see "My No Sensor Activity"
     And I should not see "My Force Sensor Activity"
     And I should not see "My Temperature Sensor Activity"
