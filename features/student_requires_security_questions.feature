Feature: Student must specify security questions before using the portal

  when I haven't set my security questions
  so that I may later reset my password
  I shouldn't be able to do anything until I set my
  security questions

  Background: portal configured with s-questions, user doesn't have them
    Given The default settings and jnlp resources exist using factories
    And the database has been seeded
    And the default settings has security questions enabled
    And the student "student" has no security questions set
    And I am logged in with the username student

    Scenario: Student forced to enter security questions
      When I try to go to my home page
      Then I should be on the edit security questions page for the user "student"

    Scenario: Student tries to navigate to their preferences
      When I try to go to my preferences
      Then I should be on the edit security questions page for the user "student"

    Scenario: Student can navigate to their home page after their security qeustions are set
      When the student "student" has security questions set
      And I go to my home page
      Then I should be on my home page

    Scenario: Student can navigate to their preferences
      When the student "student" has security questions set
      And I go to my preferences
      Then I should be on my preferences


