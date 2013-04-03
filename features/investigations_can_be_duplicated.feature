Feature: Investigations can be duplicated

  As an author
  I want to dupliate investigations
  So that I can customize it.
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the database has been seeded

  @javascript
  Scenario: Duplicating investigations have an offering count of 0
    Given I am logged in with the username author
    And I am on the investigations page for "NewestInv"
    When I duplicate the investigation
    Then the investigation "copy of NewestInv" should have been created
    And the investigation "copy of NewestInv" should have an offerings count of 0

  @javascript
  Scenario: Authors can duplicate an investigations
    Given I am logged in with the username author
    And I am on the investigations page for "NewestInv"
    When I duplicate the investigation
    Then the investigation "copy of NewestInv" should have been created

  @javascript
  Scenario: Members who are not authors cannot duplicate an investigations
    Given I am logged in with the username member
    And I am on the investigations page for "NewestInv"
    Then I cannot duplicate the investigation

  @javascript
  Scenario: Investigations with linked snapshot buttons should have their links point to the new cloned embeddable
    Given I am logged in with the username author
    And I am on the investigations page for "WithLinksInv"
    When I duplicate the investigation
    Then the investigation "copy of WithLinksInv" should have correct linked snapshot buttons

  @javascript
  Scenario: Investigations with linked prediction graphs should have their links point to the new cloned embeddable
    Given I am logged in with the username author
    And I am on the investigations page for "WithLinksInv"
    When I duplicate the investigation
    Then the investigation "copy of WithLinksInv" should have correct linked prediction graphs
