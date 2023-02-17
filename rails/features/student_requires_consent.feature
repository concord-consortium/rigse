Feature: Student must give consent for research study

  when a student registered by a teacher logs in
  so that the project safely can do research on the student data
  the student shouldn't be able to do anything until they have consented or not

  Background: portal configured with student consent
    Given The default settings exist using factories
    And the default settings has student consent enabled
    And the database has been seeded

  #@javascript
  #Scenario: Teacher signs up a student, student them must give consent on logging in
  #  When I am logged in with the username teacher
  #  And I am on "Student Roster" page for "My Class"
  #  And I click the span "Register & Add New Student"
  #  And I should see "Register & Add New Student"
  #  And I should not see "Your age"
  #  Then I fill in the following:
  #    | firstName            | Example  |
  #    | lastName             | Student  |
  #    | password             | password |
  #    | passwordConfirmation | password |
  #  And I press "Submit"
  #  And I wait for the ajax request to finish
  #  And I log out
  #  And I login with username: estudent password: password
  #  Then I should see "Your age"
  #  And I choose "user_of_consenting_age_true"
  #  And I choose "user_have_consent_true"
  #  And I press "Submit"
  #  Then I should not see "Your age"
  #  And I log out
  #  And I login with username: estudent password: password
  #  Then I should not see "Your age"


