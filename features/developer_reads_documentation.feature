Feature: A developer reads technical documentation about the software
  As a Developer
  I want to view formatted technical documentation included with this software
  So that I can learn more about how this software works
  And so I can see that documentation I write is formatted correctly before I commit it and share with other developers
  
  Background:
    Given The default project and jnlp resources exist using factories

  Scenario: A developer looks at the readme
    Given I am on /readme
    Then I should see "Technical Documentation"

  Scenario: A developer looks at a textile formatted document in the doc directory
    Given I am on /doc/core-extensions.textile
    Then I should see "Extensions to Existing Ruby Classes"

  Scenario: A developer looks at a markdown formatted document in the doc directory
    Given I am on /doc/updating_an_older_instance.md
    Then I should see "Updating an older portal instance to master"

  Scenario: A developer tries to read documentation that doesn't exist
    Given I am on /doc/does_not_exist.md
    Then I should see "Technical document: does_not_exist.md not found"

  Scenario: A developer tries to read a file that is not documentation
    Given I am on /doc/jamis.rb
    Then I should see "Document: jamis.rb not displayable"
