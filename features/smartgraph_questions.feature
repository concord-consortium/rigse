Feature: Smartgraph Questions

Authors should be able to add, edit and remove Smartgraph Range Questions to/from a page.

  As an author
  I want to add, edit or remove a Smartgraph Range Question to/from a page
  So that I can use Smartgraph Question tool.
  
  Background:
    Given The default project and jnlp resources exist using factories

  Scenario: Smartgraph question can be added to a page
    Given an author
    And a page
    When the author adds the Smartgraph Range Question to the page
    Then the Smartgraph Range Question should show on the page
    And the Smartgraph Range Question edit link should be available
    
  Scenario: Smartgraph question can be removed from a page
    Given an author
    And a page with a Smartgraph Range Question
    When the author removes the Smartgraph Range Question from the page
    Then the Smartgraph Range Question should not show on the page
    And the Smartgraph Range Question edit link should not be available
  
  Scenario: Smartgraph question can be edited in a page
    Given an author
    And a page with a Smartgraph Range Question
    When the author clicks the Smartgraph Range Question edit link
    And updates the Smartgraph Range Question data
    And clicks the Smartgraph Range Question save button
    Then the Smartgraph Range Question should show on the page
    And the Smartgraph Range Question edit link should be available
    And the Smartgraph Range Question attributes should be updated