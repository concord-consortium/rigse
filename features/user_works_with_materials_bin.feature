Feature: User works with materials bin

  As an user (logged in or not)
  I can see materials bin

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And the project "FooBar" has slug "foo-bar" and ITSI bin
      """
      <div id="bin-view"></div>
      <script>
        var MATERIALS = [
          {
            category: "Cat A",
            className: "custom-category-class",
            children: [
              {
                category: "Cat A1",
                children: [
                  {
                    collections: [
                      {id: Collection 2}
                     ]
                  }
                ]
              },
              {
                category: "Cat A2",
                children: []
              }
            ]
          },
          {
            category: "Cat B",
            children: [
              {
                category: "Cat B1",
                children: [
                  {
                    collections: [
                      {id: Collection 3}
                     ]
                  }
                ]
              },
              {
                category: "Cat B2",
                children: []
              }
            ]
          },
          {
            category: "Cat C",
            loginRequired: true,
            children: [
              {
                ownMaterials: true
              }
            ]
          },
          {
            category: "Cat D",
            children: [
              {
                materialsByAuthor: true
              }
            ]
          }
        ];
        Portal.renderMaterialsBin(MATERIALS, '#bin-view');
      </script>
      """

  @javascript
  Scenario: User sees materials bin
    When I visit the route /foo-bar
    Then category "Cat A" with class "custom-category-class" should be visible
    And category "Cat A1" should be visible
    And category "Cat A2" should be visible
    And category "Cat B" should be visible
    But category "Cat B1" should not be visible
    And category "Cat B2" should not be visible
    And category "Cat C" should not be visible
    And 2 materials should be visible

  @javascript
  Scenario: User changes category
    When I visit the route /foo-bar
    And I click category "Cat B"
    And I click category "Cat B1"
    Then 6 materials should be visible

  @javascript
  Scenario: Logged in user can see special categories
    Given I am logged in with the username author
    When I visit the route /foo-bar
    Then category "Cat C" should be visible

  @javascript
  Scenario: Author can see his own materials
    Given I am logged in with the username author
    When I visit the route /foo-bar
    And I click category "Cat C"
    Then I should see "My activities"
    And some materials should be visible

  @javascript
  Scenario: User can see materials grouped by authors
    Given I am logged in with the username teacher
    And user "foobar" authored unofficial material "ext act"
    When I visit the route /foo-bar
    And I click category "Cat D"
    Then authors list should be visible
    But no materials should be visible
    When I click "foobar" author name
    Then "ext act" material should be visible
