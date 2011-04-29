Feature: Rites Teachers see their classes and students

Rinet teachers that have been imported into the RITES portal should be able to view
Their classes, and their class students. However these teachers should not be able to edit
their imported classes. (because it comes from SIS)

  As a Rinet Teacher with imported classes
  I want to see my classes and students
  So that I can assign investigations to them
  
  Background:
    Given The default project and jnlp resources exist using mocks

  Scenario: Rinet Teachers can view their classes
    Given I am a Rinet teacher
    When I login with the link tool
    Then I should be forwarded to my home page
    And I should see a list of my classes
  
  Scenario: Rinet Teachers can view their students
    Given I am a Rinet teacher
    When I login with the link tool
    And I look at my first classes page
    Then I should see a list of my students

  Scenario: Rinet Teachers can not modify their classes
    Given I am a Rinet teacher
    When I login with the link tool
    And I look at my first classes page
    Then I should not be able to edit my classes

