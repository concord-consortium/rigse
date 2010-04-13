Feature: The Project administrator disables certain vendor interfaces
  As a Investigations project admin
  I want modify the list of supported vendor interfaces
  So that I can provide a smaller list of well tested interfaces
  
  Scenario: The project administrator removes some probe interfaces
    Given the following users exist:
      | login        | password            | roles                |
      | admin_login  | admin_password      | admin, member, author|
      | student_login| student_password    | member               |
    And I login with username: admin_login password: admin_password
    And the following vendor interfaces exist:
    | name             | description              |
    | pasco usb        | a pasco usb interface    |
    | vernier usb      | a vernier usb interface  |
    | radios hack RS232| old school interface     |
    | Texas Instruments| good old TI interface    |
    | pasco bluetooth  | pasco in the house       |
    When I go to the current project edit page
    Then I should see "Default Project"
    And I should see "Vendor Interfaces"
    Then I should see the following form checkboxes:
    | name             | checked |
    | pasco usb        | true    |
    | vernier usb      | true    |
    | radios hack RS232| true    |
    | Texas Instruments| true    |
    | pasco bluetooth  | true    |
    When I fill in the following:
    | pasco usb        | true    |
    | vernier usb      | true    |
    | radios hack RS232| false   |
    | Texas Instruments| false   |
    | pasco bluetooth  | true    |
    And I press "Save"
    Then I should see "Project was successfully updated"
    When I go to the current project edit page
    Then I should see the following form checkboxes:
    | name             | checked |
    | pasco usb        | true    |
    | vernier usb      | true    |
    | radios hack RS232| false    |
    | Texas Instruments| false    |
    | pasco bluetooth  | true    |
    




