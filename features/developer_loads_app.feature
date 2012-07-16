Feature: A developer loads home page without initializing data in database
  As a Developer
  I might load the app before I've finished the setup
  Because I don't read the documentation
  
  Scenario: A developer looks at the home page
    Given I am on the home page
    Then I should see "You need to create a project object"

