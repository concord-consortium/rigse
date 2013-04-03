Feature: Investigations can be sorted
  So I can find an investigation more efficiently
  As a teacher
  I want to sort the investigations list
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded
    Given I am logged in with the username teacher
  
  Scenario: The investigation list page has a sort mechanism
    When I am on the investigations page
    Then the sort order selection should be "name ASC"

  @javascript
  Scenario: The investigations list can be sorted by name
    When I sort investigations by "name ASC"
    Then "MediumInv" should appear before "NewestInv"
    And "NewestInv" should appear before "OldestInv"

  @javascript
  Scenario: The investigations list can be sorted by date created
    When I sort investigations by "created_at DESC"
    Then "NewestInv" should appear before "MediumInv"
    And "MediumInv" should appear before "OldestInv"
    
  @javascript
  Scenario: The investigations list can be sorted by offerings count
    When I sort investigations by "offerings_count DESC"
    Then "OldestInv" should appear before "MediumInv"
    And "MediumInv" should appear before "NewestInv"
    
