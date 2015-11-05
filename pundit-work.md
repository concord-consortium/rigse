# Pundit Work

## Controllers

### Completed on first pass

* Y api/api_controller.rb
* Y api/v1/students_controller.rb
* Y api/v1/teachers_controller.rb
* Y browse/external_activities_controller.rb
* Y browse/investigations_controller.rb
* Y dataservice/bucket_contents_metal_controller.rb
* Y dataservice/bucket_log_items_metal_controller.rb
* Y dataservice/bundle_contents_metal_controller.rb
* Y dataservice/console_contents_metal_controller.rb
* Y dataservice/periodic_bundle_contents_metal_controller.rb
* Y misc_controller.rb
* Y otrunk_example/otml_categories_controller.rb
* Y otrunk_example/otml_files_controller.rb
* Y otrunk_example/otrunk_imports_controller.rb
* Y otrunk_example/otrunk_view_entries_controller.rb
* Y page_elements_controller.rb
* Y portal/school_selector_controller.rb
* Y probe/calibrations_controller.rb
* Y probe/data_filters_controller.rb
* Y probe/device_configs_controller.rb
* Y probe/physical_units_controller.rb
* Y probe/vendor_interfaces_controller.rb
* Y ri_gse/big_ideas_controller.rb
* Y ri_gse/domains_controller.rb
* Y ri_gse/expectations_controller.rb
* Y ri_gse/expectation_stems_controller.rb
* Y ri_gse/knowledge_statements_controller.rb
* Y ri_gse/unifying_themes_controller.rb
* Y saveable/sparks/measuring_resistances_controller.rb

### Need to resolve PeerAccess

* Y dataservice/external_activity_data_controller.rb

### Modified but need to resolve PeerAccess and authorization

* P api/v1/collaborations_controller.rb

### Modified but need to resolve PeerAccess, filters and scope

* P external_activities_controller.rb

### Not modified after auto edit but need to resolve PeerAccess

* N admin/learner_details_controller.rb

### Need to resolve RestrictedBundleController

* Y dataservice/periodic_bundle_loggers_controller.rb

### Modified but need to resolve RestrictedBundleController

* P dataservice/bucket_loggers_controller.rb

### Modified but need to resolve RestrictedBundleController and scope

* P dataservice/bundle_contents_controller.rb
* P dataservice/bundle_loggers_controller.rb
* P dataservice/console_contents_controller.rb
* P dataservice/console_loggers_controller.rb

### Need to resolve RestrictedPortalController
* Y portal/courses_controller.rb
* Y portal/semesters_controller.rb
* Y portal/student_clazzes_controller.rb
* Y portal/subjects_controller.rb

### Modified but need to resolve RestrictedPortalController and filters

* P portal/clazzes_controller.rb
* P portal/grades_controller.rb
* P portal/grade_levels_controller.rb
* P portal/offerings_controller.rb
* P portal/school_memberships_controller.rb
* P portal/students_controller.rb
* P portal/teachers_controller.rb

### Modified but need to resolve RestrictedPortalController and filters and scope

* P portal/districts_controller.rb
* P portal/learners_controller.rb
* P portal/nces06_districts_controller.rb
* P portal/nces06_schools_controller.rb
* P portal/schools_controller.rb

### Modified but need to resolve RestrictedController and filters

* P installer_reports_controller.rb
* P investigations_controller.rb

### Modified but need to resolve RestrictedController and filters and scope

* P materials_collections_controller.rb
* P report/learner_controller.rb
* P search_controller.rb

### Modified but needs scope work (not using search)

* P api/v1/countries_controller.rb
* P api/v1/districts_controller.rb
* P api/v1/schools_controller.rb
* P api/v1/security_questions_controller.rb
* P api/v1/states_controller.rb
* P portal/user_type_selector_controller.rb
* P probe/probe_types_controller.rb

### Modified but needs scope work (uses search)

* P activities_controller.rb
* P embeddable/biologica/breed_offsprings_controller.rb
* P embeddable/biologica/chromosomes_controller.rb
* P embeddable/biologica/chromosome_zooms_controller.rb
* P embeddable/biologica/meiosis_views_controller.rb
* P embeddable/biologica/multiple_organisms_controller.rb
* P embeddable/biologica/organisms_controller.rb
* P embeddable/biologica/pedigrees_controller.rb
* P embeddable/biologica/static_organisms_controller.rb
* P embeddable/biologica/worlds_controller.rb
* P embeddable/data_collectors_controller.rb
* P embeddable/data_tables_controller.rb
* P embeddable/drawing_tools_controller.rb
* P embeddable/image_questions_controller.rb
* P embeddable/inner_pages_controller.rb
* P embeddable/lab_book_snapshots_controller.rb
* P embeddable/multiple_choices_controller.rb
* P embeddable/mw_modeler_pages_controller.rb
* P embeddable/n_logo_models_controller.rb
* P embeddable/open_responses_controller.rb
* P embeddable/raw_otmls_controller.rb
* P embeddable/smartgraph/range_questions_controller.rb
* P embeddable/sound_graphers_controller.rb
* P embeddable/video_players_controller.rb
* P embeddable/xhtmls_controller.rb
* P resource_pages_controller.rb
* P ri_gse/assessment_targets_controller.rb

### Modified but needs filter work

* P attached_files_controller.rb
* P author_notes_controller.rb

### Modified but needs filter and authorization work

* P teacher_notes_controller.rb
* P import/imports_controller.rb

### Modified but needs scope and filter work

* P admin/permission_forms_controller.rb
* P admin/projects_controller.rb
* P admin/settings_controller.rb
* P admin/site_notices_controller.rb
* P admin/tags_controller.rb
* P dataservice/blobs_controller.rb
* P images_controller.rb
* P interactives_controller.rb
* P pages_controller.rb
* P sections_controller.rb

### Modified but needs scope and authorization work

* P portal/bookmarks_controller.rb
* P ri_gse/grade_span_expectations_controller.rb

### Modified but needs custom error message

* P browse/activities_controller.rb

### Modified but need to resolve authorization

* P help_controller.rb
* P registrations_controller.rb

### Modified but need to double check authorization

* P passwords_controller.rb

### Not modified after auto edit needs authorization work

* N api/v1/materials_bin_controller.rb
* N api/v1/materials_controller.rb
* N api/v1/search_controller.rb
* N dataservice/periodic_bundle_loggers_metal_controller.rb
* N home_controller.rb
* N import/imported_login_controller.rb
* N portal/learner_jnlp_renderer.rb
* N portal/offerings_metal_controller.rb

### Not modified after auto edit needs filter work

* N authoring_controller.rb

### Not modified after auto edit needs filter and authorization work

* N auth_controller.rb
* N security_questions_controller.rb
* N users_controller.rb

### Not modified after auto edit - no work needed?

* N application_controller.rb
* N authentications_controller.rb
* N misc_metal_controller.rb
