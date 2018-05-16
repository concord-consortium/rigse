Feature: Teacher can search and assign instructional materials to a class

  As a teacher
  I should be able to preview and assign materials to a class
  In order to provide study materials to the students from the class
  
  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And I am logged in with the username teacher

  @javascript
  Scenario: Teacher should be able to preview materials activity as teacher and as a student
    When I am on the material preview page for "Atomic Energy"
    Then I should see "Requirements"
    And I should see "You may also like"
    And I should see the preview button for "Atomic Energy"
    And I should see the assignment button for "Atomic Energy"

    