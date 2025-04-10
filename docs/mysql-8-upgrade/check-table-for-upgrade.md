# Check Table for Upgrade

The tables listed below were identified by AWS as requiring a rebuild before the database could be upgraded. The command used to determine this was `check table x for upgrade`.

- portal.admin_notice_user_display_statuses
- portal.admin_project_links
- portal.admin_project_materials
- portal.admin_projects
- portal.admin_settings
- portal.admin_site_notice_users
- portal.admin_site_notices
- portal.admin_tags
- portal.authoring_sites
- portal.clients
- portal.commons_licenses
- portal.delayed_jobs
- portal.favorites
- portal.firebase_apps
- portal.images
- portal.imports
- portal.interactives
- portal.materials_collection_items
- portal.materials_collections
- portal.passwords
- portal.portal_bookmark_visits
- portal.portal_bookmarks
- portal.portal_collaboration_memberships
- portal.portal_collaborations
- portal.portal_countries
- portal.portal_courses
- portal.portal_districts
- portal.portal_grades
- portal.portal_learners
- portal.portal_offerings
- portal.portal_school_memberships
- portal.portal_schools
- portal.portal_student_clazzes
- portal.portal_student_permission_forms
- portal.portal_students
- portal.portal_subjects
- portal.portal_teacher_clazzes
- portal.portal_teachers
- portal.report_learners
- portal.sessions
- portal.standard_documents
- portal.standard_statements
- portal.teacher_project_views

## Alter Queries

To fix this issue, run the queries below.

Note that some of these may be duplicates of the queries in `old-temporal-type.md`. See `unique-queries.md` for a de-duped list.

```sql
ALTER TABLE admin_notice_user_display_statuses FORCE;
ALTER TABLE admin_project_links FORCE;
ALTER TABLE admin_project_materials FORCE;
ALTER TABLE admin_projects FORCE;
ALTER TABLE admin_settings FORCE;
ALTER TABLE admin_site_notice_users FORCE;
ALTER TABLE admin_site_notices FORCE;
ALTER TABLE admin_tags FORCE;
ALTER TABLE authoring_sites FORCE;
ALTER TABLE clients FORCE;
ALTER TABLE commons_licenses FORCE;
ALTER TABLE delayed_jobs FORCE;
ALTER TABLE favorites FORCE;
ALTER TABLE firebase_apps FORCE;
ALTER TABLE images FORCE;
ALTER TABLE imports FORCE;
ALTER TABLE interactives FORCE;
ALTER TABLE materials_collection_items FORCE;
ALTER TABLE materials_collections FORCE;
ALTER TABLE passwords FORCE;
ALTER TABLE portal_bookmark_visits FORCE;
ALTER TABLE portal_bookmarks FORCE;
ALTER TABLE portal_collaboration_memberships FORCE;
ALTER TABLE portal_collaborations FORCE;
ALTER TABLE portal_countries FORCE;
ALTER TABLE portal_courses FORCE;
ALTER TABLE portal_districts FORCE;
ALTER TABLE portal_grades FORCE;
ALTER TABLE portal_learners FORCE;
ALTER TABLE portal_offerings FORCE;
ALTER TABLE portal_school_memberships FORCE;
ALTER TABLE portal_schools FORCE;
ALTER TABLE portal_student_clazzes FORCE;
ALTER TABLE portal_student_permission_forms FORCE;
ALTER TABLE portal_students FORCE;
ALTER TABLE portal_subjects FORCE;
ALTER TABLE portal_teacher_clazzes FORCE;
ALTER TABLE portal_teachers FORCE;
ALTER TABLE report_learners FORCE;
ALTER TABLE sessions FORCE;
ALTER TABLE standard_documents FORCE;
ALTER TABLE standard_statements FORCE;
ALTER TABLE teacher_project_views FORCE;
```
