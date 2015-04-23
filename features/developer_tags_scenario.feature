Feature: A developer can tag a scenario to enable a project setting
  As a Developer
  I want to test a scenario with a particular setting
  Because the scenario requires it

  @enable_gses
  Scenario: The use_gse setting should be enabled
    Then APP_CONFIG[:use_gse] should be true

  @disable_gses
  Scenario: The use_gse setting should not be enabled
    Then APP_CONFIG[:use_gse] should be false
