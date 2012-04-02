Feature: An author edits a data collector
  As a Investigations author
  I want to author data collectors in my investigations
  So that I can provoke exploration by my students.

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following users exist:
      | login        | password            | roles                |
      | author       | author              | member, author       |
    And I login with username: author password: author

  @javascript
  Scenario: The author edits a graph and sees the Y-axis label and units change as the probe type changes
    Given the following simple investigations exist:
      | name                 | description           | user                 |
      | testing fast cars    | how fast can cars go? | author               |

    When I show the first page of the "testing fast cars" investigation
    Then I should see "Page: testing fast cars"
    When I add a "Graph" to the page
    Then I should see "Data Collector"
    When I follow "edit graph"
    Then I should see "Sensor Graph:"
    When I select "Pressure" from "embeddable_data_collector[probe_type_id]"
    Then the "embeddable_data_collector_y_axis_label" field should contain "Pressure"
    And the "embeddable_data_collector_y_axis_units" field should contain "kPa"


  @javascript
  Scenario: The author edits a graph from list of graphs
    Given I created a data collector
    When I visit /embeddable/data_collectors
    And I follow "edit graph"
    Then I should see "Probe type"
