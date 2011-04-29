Feature: Sakai Integration

Sakai users that have been imported into the Investigations instance should be able to access
Investigations via the Sakai Linktool instance without needing to re-authenticate themselves.
If the user has not been imported, they should get a friendly error message telling them so.

  As a valid Sakai user
  I want to access investigations without re-authenticating
  So that I can use the investigations tools.
  
  Background:
    Given The default project and jnlp resources exist using mocks

  Scenario: Sakai user can access investigations
    Given PENDING: this scenario needs to be fixed
    Given a valid sakai user
    When the user goes to the link tool url
    Then the user should be logged in
    And the user should be forwarded to their home page
  
  Scenario: Unknown sakai user can not access investigations
    Given an unknown sakai user
    When the user goes to the link tool url
    Then the user should not be logged in
    And the user should be shown a helpful error message