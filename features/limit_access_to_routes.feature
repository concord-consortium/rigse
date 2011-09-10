Feature: Limit access to restricted routes

Only logged in users with appropriate roles should be able to see and change resources in the portal.

If a user without the appropriate role or permissions attempts to access a resource the system should redirect the user with an appropriate warning message.

In NO case should the system allow:
* access to private student data to unauthorized users
* unauthorized users to edit or delete resources they shouldn't

  As a person concerned about security
  I want ensure that I can not access restricted routes
  So that we can protect our users data

  Background:
    Given The default project and jnlp resources exist using factories

  Scenario Outline: Anonymous user cant access dataservice routes
    Given I am not logged in
    When I visit the route <route>
    Then I should be on my home page

    Examples:
      | route                         |
      | /dataservice/bundle_contents  |
      | /dataservice/bundle_loggers   |
      | /dataservice/console_loggers  |
      | /dataservice/console_contents |
      | /dataservice/blobs            |

  Scenario Outline: Admin user can accesss dataservice routes
    Given the following users exist:
      | login       | password       | roles                 |
      | admin_login | admin_password | admin, member, author |
    And I login with username: admin_login password: admin_password
    When I visit the route <route>
    Then I should be on <route>

    Examples:
      | route                         |
      | /dataservice/bundle_contents  |
      | /dataservice/bundle_loggers   |
      | /dataservice/console_loggers  |
      | /dataservice/console_contents |
      | /dataservice/blobs            |

  Scenario Outline: Anonymous user can't access portal listing routes:
    Given I am not logged in
    When I visit the route <route>
    Then I should be on my home page

    Examples:
      | route                         |
      | /portal/clazzes               |
      | /portal/courses               |
      | /portal/school_memberships    |
      | /portal/schools               |
      | /portal/semesters             |
      | /portal/student_clazzes       |
      | /portal/students              |
      | /portal/subjects              |
      | /portal/teachers              |
      | /portal/districts             |
      | /portal/grades                |
      | /portal/learners              |
      | /portal/external_user_domains |
      | /portal/external_users        |
      | /portal/grade_levels          |
      | /portal/nces06_districts      |
      | /portal/nces06_schools        |
      | /portal/offerings             |
      | /portal/teachers              |

  Scenario Outline: Admin user can accesss portal listing routes
    Given the following users exist:
      | login       | password       | roles                 |
      | admin_login | admin_password | admin, member, author |
    And I login with username: admin_login password: admin_password
    When I visit the route <route>
    Then I should be on <route>

    Examples:
      | route                         |
      | /portal/clazzes               |
      | /portal/courses               |
      | /portal/school_memberships    |
      | /portal/schools               |
      | /portal/semesters             |
      | /portal/student_clazzes       |
      | /portal/students              |
      | /portal/subjects              |
      | /portal/teachers              |
      | /portal/districts             |
      | /portal/grades                |
      | /portal/learners              |
      | /portal/external_user_domains |
      | /portal/external_users        |
      | /portal/grade_levels          |
      | /portal/nces06_districts      |
      | /portal/nces06_schools        |
      | /portal/offerings             |

  Scenario Outline: Anonymous user can't access user listing routes:
    Given I am not logged in
    When I visit the route <route>
    Then I should be on my home page

    Examples:
      | route  |
      | /users |

  Scenario Outline: Admin user can accesss user listing routes
    Given the following users exist:
      | login       | password       | roles                 |
      | admin_login | admin_password | admin, member, author |
    And I login with username: admin_login password: admin_password
    When I visit the route <route>
    Then I should be on <route>

    Examples:
      | route  |
      | /users |
