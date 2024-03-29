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
    Given The default settings exist using factories
    And the database has been seeded

  Scenario Outline: Anonymous user can't access portal listing routes:
    Given I am not logged in
    When I visit the route <route>
    Then I should be on the signin page

    Examples:
      | route                         |
      | /portal/classes               |
      | /portal/courses               |
      | /portal/school_memberships    |
      | /portal/schools               |
      | /portal/student_clazzes       |
      | /portal/students              |
      | /portal/subjects              |
      | /portal/districts             |
      | /portal/nces06_districts      |
      | /portal/nces06_schools        |

  Scenario Outline: Admin user can accesss portal listing routes
    Given the following users exist:
      | login       | password       | roles                 |
      | admin_login | admin_password | admin, member, author |
    Given I am logged in with the username admin_login
    When I visit the route <route>
    Then I should be on <route>

    Examples:
      | route                         |
      | /portal/classes               |
      | /portal/courses               |
      | /portal/school_memberships    |
      | /portal/schools               |
      | /portal/student_clazzes       |
      | /portal/students              |
      | /portal/subjects              |
      | /portal/districts             |
      | /portal/nces06_districts      |
      | /portal/nces06_schools        |

  Scenario Outline: Anonymous user can't access user listing routes:
    Given I am not logged in
    When I visit the route <route>
    Then I should be on the signin page

    Examples:
      | route  |
      | /users |

  Scenario Outline: Admin user can accesss user listing routes
    Given the following users exist:
      | login       | password       | roles                 |
      | admin_login | admin_password | admin, member, author |
    And I am logged in with the username admin_login
    When I visit the route <route>
    Then I should be on <route>

    Examples:
      | route  |
      | /users |

  Scenario Outline: Anonymous user can't access report learner routes:
    Given I am not logged in
    When I visit the route <route>
    Then I should be on the signin page

    Examples:
      | route           |
      | /report/learner |

  Scenario Outline: Admin user can accesss report learner routes
    Given the following users exist:
      | login       | password       | roles                 |
      | admin_login | admin_password | admin, member, author |
    And I am logged in with the username admin_login
    When I visit the route <route>
    Then I should be on <route>

    Examples:
      | route           |
      | /report/learner |

  Scenario Outline: Researcher user can accesss report learner routes
    Given the following users exist:
      | login            | password            | roles              |
      | researcher_login | researcher_password | member, researcher |
    And I am logged in with the username researcher_login
    When I visit the route <route>
    Then I should be on <route>

    Examples:
      | route           |
      | /report/learner |
