# Unique Queries

This is a list of unique queries that will fix both the Old Temporal Type and the Check Table for Upgrade issues.

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
ALTER TABLE admin_site_notices FORCE;
ALTER TABLE portal_subjects FORCE;
ALTER TABLE report_learners FORCE;
ALTER TABLE standard_statements FORCE;
```

In addition to the above, the queries below should be run. This is a copy of the queries in `utf8mb3.md` and included here to make the list of unique queries complete.

```sql
ALTER DATABASE portal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE admin_cohort_items CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE admin_cohorts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE admin_project_links CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE admin_project_materials CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE admin_projects CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE admin_settings CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE admin_site_notices CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE admin_tags CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE ar_internal_metadata CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE authentications CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE authoring_sites CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE clients CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE commons_licenses CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE delayed_jobs CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE external_activities CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE external_reports CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE favorites CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE firebase_apps CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE images CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE import_duplicate_users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE import_school_district_mappings CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE import_user_school_mappings CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE imported_users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE imports CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE interactives CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE materials_collection_items CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE materials_collections CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE passwords CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_bookmarks CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_clazzes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_countries CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_courses CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_districts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_grade_levels CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_grades CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_learners CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_nces06_districts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_nces06_schools CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_offerings CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_permission_forms CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_school_memberships CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_schools CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_student_clazzes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_students CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_subjects CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_teacher_clazzes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE portal_teachers CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE report_learners CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE roles CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE schema_migrations CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE security_questions CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE standard_documents CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE standard_statements CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE taggings CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE tags CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE tools CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

There is one other query to run to update the charset:
```sql
ALTER TABLE sessions CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

However, since the `sessions` table contains a huge amount of data, it is faster to run these:
```sql
ALTER TABLE sessions CHANGE COLUMN session_id session_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, CHANGE COLUMN data data MEDIUMTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE sessions DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```
