Only logged in users with appropriate roles should be able to see and change resources in the portal.

If a user without the appropriate role or permissions attempts to access a resource the system should redirect the user with an appropriate warning message.

In NO case should the system allow:
* access to private student data to unauthorized users
* unauthorized users to edit or delete resources they shouldn't

Feature: Limit access to restricted routes
  As a person concerned about security
  I want ensure that I can not access restricted routes
  So that we can protect our users data
  
  
  Scenario Outline: Anonymous user cant access dataservice routes
    Given I am not logged in
    When I visit the route <route>
    Then I should <action>
  
    Examples:
      | route                          | action                         |
      | /dataservice/bundle_contents   | be redirected home             |
      | /dataservice/bundle_loggers    | be redirected home             |
      | /dataservice/console_loggers   | be redirected home             |
      | /dataservice/console_contents  | be redirected home             |
  
  Scenario: Admin user is valid
    Then There should be a valid admin user
    
  Scenario Outline: Admin user can accesss dataservice routes
    Given I am logged in as the admin user
    When I visit the route <route>
    Then I should <action>
    
    Examples:
      | route                          | action                         |
      | /dataservice/bundle_contents   | not be redirected home         |
      | /dataservice/bundle_loggers    | not be redirected home         |
      | /dataservice/console_loggers   | not be redirected home         |
      | /dataservice/console_contents  | not be redirected home         |