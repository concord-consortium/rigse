# Old Temporal Type

The following table columns use a no-longer-supported temporal disk storage format. They must be converted to the new format before upgrading. It can by done by rebuilding the table using `ALTER TABLE <table_name> FORCE'` command.

[documentation](https://mysqlserverteam.com/mysql-8-0-removing-support-for-old-temporal-datatypes/)

- portal.admin_notice_user_display_statuses.last_collapsed_at_time
- portal.admin_project_links.created_at
- portal.admin_project_links.updated_at
- portal.admin_project_materials.created_at
- portal.admin_project_materials.updated_at
- portal.admin_projects.created_at
- portal.admin_projects.updated_at
- portal.admin_settings.created_at
- portal.admin_settings.updated_at
- portal.admin_site_notice_users.created_at
- portal.admin_site_notice_users.updated_at
- portal.admin_site_notices.created_at
- portal.admin_site_notices.updated_at
- portal.admin_tags.created_at
- portal.admin_tags.updated_at
- portal.authoring_sites.created_at
- portal.authoring_sites.updated_at
- portal.clients.created_at
- portal.clients.updated_at
- portal.commons_licenses.created_at
- portal.commons_licenses.updated_at
- portal.delayed_jobs.run_at
- portal.delayed_jobs.locked_at
- portal.delayed_jobs.failed_at
- portal.delayed_jobs.created_at
- portal.delayed_jobs.updated_at
- portal.favorites.created_at
- portal.favorites.updated_at
- portal.firebase_apps.created_at
- portal.firebase_apps.updated_at
- portal.images.created_at
- portal.images.updated_at
- portal.images.image_updated_at
- portal.imports.job_finished_at
- portal.imports.created_at
- portal.imports.updated_at
- portal.interactives.created_at
- portal.interactives.updated_at
- portal.materials_collection_items.created_at
- portal.materials_collection_items.updated_at
- portal.materials_collections.created_at
- portal.materials_collections.updated_at
- portal.passwords.expiration_date
- portal.passwords.created_at
- portal.passwords.updated_at
- portal.portal_bookmark_visits.created_at
- portal.portal_bookmark_visits.updated_at
- portal.portal_bookmarks.created_at
- portal.portal_bookmarks.updated_at
- portal.portal_collaboration_memberships.created_at
- portal.portal_collaboration_memberships.updated_at
- portal.portal_collaborations.created_at
- portal.portal_collaborations.updated_at
- portal.portal_countries.created_at
- portal.portal_countries.updated_at
- portal.portal_courses.created_at
- portal.portal_courses.updated_at
- portal.portal_districts.created_at
- portal.portal_districts.updated_at
- portal.portal_grades.created_at
- portal.portal_grades.updated_at
- portal.portal_learners.created_at
- portal.portal_learners.updated_at
- portal.portal_offerings.created_at
- portal.portal_offerings.updated_at
- portal.portal_school_memberships.start_time
- portal.portal_school_memberships.end_time
- portal.portal_school_memberships.created_at
- portal.portal_school_memberships.updated_at
- portal.portal_schools.created_at
- portal.portal_schools.updated_at
- portal.portal_student_clazzes.start_time
- portal.portal_student_clazzes.end_time
- portal.portal_student_clazzes.created_at
- portal.portal_student_clazzes.updated_at
- portal.portal_student_permission_forms.created_at
- portal.portal_student_permission_forms.updated_at
- portal.portal_students.created_at
- portal.portal_students.updated_at
- portal.portal_subjects.created_at
- portal.portal_subjects.updated_at
- portal.portal_teacher_clazzes.start_time
- portal.portal_teacher_clazzes.end_time
- portal.portal_teacher_clazzes.created_at
- portal.portal_teacher_clazzes.updated_at
- portal.portal_teachers.created_at
- portal.portal_teachers.updated_at
- portal.report_learners.last_run
- portal.report_learners.last_report
- portal.sessions.created_at
- portal.sessions.updated_at
- portal.standard_documents.created_at
- portal.standard_documents.updated_at
- portal.standard_statements.created_at
- portal.standard_statements.updated_at
- portal.teacher_project_views.created_at
- portal.teacher_project_views.updated_at

## Alter Queries

To fix this issue, run the queries below.

Note that some of these may be duplicates of the queries in `check-table-for-upgrade.md`. See `unique-queries.md` for a de-duped list.

```sql
ALTER TABLE access_grants FORCE;
ALTER TABLE admin_notice_user_display_statuses FORCE;
ALTER TABLE admin_project_links FORCE;
ALTER TABLE admin_project_materials FORCE;
ALTER TABLE admin_projects FORCE;
ALTER TABLE admin_settings FORCE;
ALTER TABLE admin_site_notice_users FORCE;
ALTER TABLE admin_tags FORCE;
ALTER TABLE ar_internal_metadata FORCE;
ALTER TABLE authentications FORCE;
ALTER TABLE authoring_sites FORCE;
ALTER TABLE clients FORCE;
ALTER TABLE commons_licenses FORCE;
ALTER TABLE delayed_jobs FORCE;
ALTER TABLE external_activities FORCE;
ALTER TABLE external_reports FORCE;
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
ALTER TABLE portal_clazzes FORCE;
ALTER TABLE portal_collaboration_memberships FORCE;
ALTER TABLE portal_collaborations FORCE;
ALTER TABLE portal_countries FORCE;
ALTER TABLE portal_courses FORCE;
ALTER TABLE portal_districts FORCE;
ALTER TABLE portal_grade_levels FORCE;
ALTER TABLE portal_grades FORCE;
ALTER TABLE portal_learners FORCE;
ALTER TABLE portal_offerings FORCE;
ALTER TABLE portal_permission_forms FORCE;
ALTER TABLE portal_runs FORCE;
ALTER TABLE portal_school_memberships FORCE;
ALTER TABLE portal_schools FORCE;
ALTER TABLE portal_student_clazzes FORCE;
ALTER TABLE portal_student_permission_forms FORCE;
ALTER TABLE portal_students FORCE;
ALTER TABLE portal_teacher_clazzes FORCE;
ALTER TABLE portal_teachers FORCE;
ALTER TABLE sessions FORCE;
ALTER TABLE standard_documents FORCE;
ALTER TABLE taggings FORCE;
ALTER TABLE teacher_project_views FORCE;
ALTER TABLE users FORCE;
```
