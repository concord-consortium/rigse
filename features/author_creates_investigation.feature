Feature: An author creates an investigation
  As a Investigations author
  I want to create an investigation
  So that students can take it.

  Background:
    Given The default project and jnlp resources exist using factories

  @selenium
  Scenario: The author creates an investigation
    Given a mock gse
    Given the following users exist:
      | login        | password            | roles                |
      | author       | author              | member, author       |
    And I login with username: author password: author
    When I go to the create investigation page
    Then I should see "Investigation: (new)"
    When I fill in the following:
      | investigation[name]           | Test Investigation    |
      | investigation[description]    | testing testing 1 2 3 |
    And I save the investigation
    Then I should see "Investigation was successfully created."

  #@selenium
  #Scenario: The author creates a RITES investigation
    #Given a mock gse
    #Given the following users exist:
      #| login        | password            | roles                |
      #| author       | author              | member, author       |
    #And I login with username: author password: author
    #When I go to the create investigation page
    #Then I should see "Investigation: (new)"
    #And I should see "grade span"
    #And I should see "domain"
