Feature: Teacher can search investigations and activities
  
  As a teacher
  I should be able to search investigations and activities
  In order to find investigations and activities
  
  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login    | password | first_name   | last_name |
      | teacher  | teacher  | John         | Nash      |
    And the following multiple choice questions exists:
      | prompt | answers | correct_answer |
      | a      | a,b,c,d | a              |
      | b      | a,b,c,d | a              |
    And there is an image question with the prompt "image_q"
    And the following investigations with multiple choices exist:
      | investigation      | activity              | section   | page   | multiple_choices | image_questions | user      |
      | Radioactivity      | Radio active elements | section a | page 1 | a                | image_q         | teacher   |
      | Radioactivity      | Nuclear Energy        | section a | page 1 | a                | image_q         | teacher   |
      | Plant reproduction | Plant activity        | section b | page 2 | b                | image_q         | teacher   |
    And I login with username: teacher password: teacher
    And I am on the search page
    
    
  @javascript
  Scenario: Teacher should land on search page after following "Browse Instructional Materials"
    When I follow "Browse Instructional Materials"
    Then I should be on the search page
    
    
  @javascript
  Scenario: Teacher can see all the investigations
    Then I should see "Radioactivity"
    And I should see "Plant reproduction"
    
    
  @javascript
  Scenario: Teacher can see all the activities
    Then I should see "Radio active elements"
    And I should see "Nuclear Energy"
    And I should see "Plant activity"
    
    
  @javascript
  Scenario: Teacher can search investigations and activities from search box
    When I fill in "search_term" with "Radio"
    And I press "GO"
    Then I should see "Radioactivity"
    And I should see "Radio active elements"
    
    
  @javascript
  Scenario: Teacher can see the suggestions in the search suggestion
    When I fill in "search_term" with "Plant"
    And I should see "Plant activity" within the search suggestion
    
    
  @javascript
  Scenario: Teacher can search investigations and activities from search box
    When I fill in "search_term" with "Random interactivity"
    Then I should see "No Results Found"
    
    
  @javascript
  Scenario: Anonymous user cannot see the page
    When I am an anonymous user
    And I go to the search page
    Then I should be on "the home page"
    
    