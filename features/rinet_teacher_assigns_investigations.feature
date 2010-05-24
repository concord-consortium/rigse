Feature: Rites Teachers selects offerings to assign to their classes
  As a Rinet Teacher with imported classes
  I want to assign investigations to my classes
  So that my students can have rich learning experiences

  Background:
    Given The default project and jnlp resources exist using mocks

  Scenario: Rinet Teachers can view their classes
    Given I am a Rinet teacher
    When I login with the link tool
    And I look at my first classes page
    Then I should see a list of investigations
    
  Scenario: Rinet Teachers can view their classes
    Given I am a Rinet teacher
    When I login with the link tool
    And I look at my first classes page
    And I click on "assign to class"
    Then The invstigation should be assigned to my class