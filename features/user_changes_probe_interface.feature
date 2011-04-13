Feature: A user changes which probeware interface they are using

  As a user
  I want to change my probeware interface
  In order to use the specific type of probeware I have

  Background:
    Given The default project and jnlp resources exist using factories

  Scenario: Student changes probeware interface on preferences page
    Given the following students exist:
      | login     | password  |
      | student   | student   |
    And I login with username: student password: student
    When I go to my preferences
    And I select "Fourier Ecolog" from "user_vendor_interface_id"
    And I press "Save"
    Then I should not see "Please log in as an administrator"
    And I should see "was successfully updated"


