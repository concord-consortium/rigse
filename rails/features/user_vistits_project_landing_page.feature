Feature: User can visit custom project landing page

  As an user (logged in or not)
  I can see custom project page content

  Background:
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And the project "FooBar" has slug "foo-bar" and landing page
      """
      Hello, <span id='foo-bar'></span><script>jQuery('#foo-bar').text('it is FooBar page!');</script>
      """

  @javascript
  Scenario: Logged in user vists projects landing page
    Given I am logged in with the username author
    When I visit the route /foo-bar
    Then I should see "Hello, it is FooBar page!"

  @javascript
  Scenario: Anonymous user vists projects landing page
    When I visit the route /foo-bar
    Then I should see "Hello, it is FooBar page!"