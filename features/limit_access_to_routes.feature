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



  Scenario Outline: Anonymous user can't access portal listing routes:
    Given I am not logged in
    When I visit the route <route>
    Then I should <action>
    
    Examples:
      | route                                      | action             |
      | /portal/clazzes                            | be redirected home |
      | /portal/courses                            | be redirected home |
      | /portal/school_memberships                 | be redirected home |
      | /portal/schools                            | be redirected home |
      | /portal/semesters                          | be redirected home |
      | /portal/student_clazzes                    | be redirected home |
      | /portal/students                           | be redirected home |
      | /portal/subjects                           | be redirected home |
      | /portal/teachers                           | be redirected home |
      | /portal/districts                          | be redirected home |
      | /portal/grades                             | be redirected home |
      | /portal/learners                           | be redirected home |
      | /portal/external_user_domains              | be redirected home |
      | /portal/external_users                     | be redirected home |
      | /portal/grade_levels                       | be redirected home |
      | /portal/home                               | be redirected home |
      | /portal/nces06_districts                   | be redirected home |
      | /portal/nces06_schools                     | be redirected home |
      | /portal/offerings                          | be redirected home |
      | /portal/teachers                           | be redirected home |
      
      
  Scenario Outline: Admin user can accesss portal listing routes
    Given I am logged in as the admin user
    When I visit the route <route>
    Then I should <action>

    Examples:
      | route                                      | action                 |
      | /portal/clazzes                            | not be redirected home |
      | /portal/courses                            | not be redirected home |
      | /portal/school_memberships                 | not be redirected home |
      | /portal/schools                            | not be redirected home |
      | /portal/semesters                          | not be redirected home |
      | /portal/student_clazzes                    | not be redirected home |
      | /portal/students                           | not be redirected home |
      | /portal/subjects                           | not be redirected home |
      | /portal/teachers                           | not be redirected home |
      | /portal/districts                          | not be redirected home |
      | /portal/grades                             | not be redirected home |
      | /portal/learners                           | not be redirected home |
      | /portal/external_user_domains              | not be redirected home |
      | /portal/external_users                     | not be redirected home |
      | /portal/grade_levels                       | not be redirected home |
      | /portal/home                               | not be redirected home |
      | /portal/nces06_districts                   | not be redirected home |
      | /portal/nces06_schools                     | not be redirected home |
      | /portal/offerings                          | not be redirected home |
      | /portal/teachers                           | not be redirected home |