# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_29_153107) do

  create_table "access_grants", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "code"
    t.string "access_token"
    t.string "refresh_token"
    t.datetime "access_token_expires_at"
    t.integer "user_id"
    t.integer "client_id"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "learner_id"
    t.integer "teacher_id"
    t.index ["client_id"], name: "index_access_grants_on_client_id"
    t.index ["learner_id"], name: "index_access_grants_on_learner_id"
    t.index ["teacher_id"], name: "index_access_grants_on_teacher_id"
    t.index ["user_id"], name: "index_access_grants_on_user_id"
  end

  create_table "activities", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "investigation_id"
    t.integer "original_id"
    t.boolean "teacher_only", default: false
    t.string "publication_status"
    t.integer "offerings_count", default: 0
    t.boolean "student_report_enabled", default: true
    t.boolean "show_score", default: false
    t.string "teacher_guide_url"
    t.string "thumbnail_url"
    t.boolean "is_featured", default: false
    t.boolean "is_assessment_item", default: false
    t.index ["investigation_id", "position"], name: "index_activities_on_investigation_id_and_position"
    t.index ["is_featured", "publication_status"], name: "featured_public"
    t.index ["publication_status"], name: "pub_status"
  end

  create_table "admin_cohort_items", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "admin_cohort_id"
    t.integer "item_id"
    t.string "item_type"
    t.index ["admin_cohort_id"], name: "index_admin_cohort_items_on_admin_cohort_id"
    t.index ["item_id"], name: "index_admin_cohort_items_on_item_id"
    t.index ["item_type"], name: "index_admin_cohort_items_on_item_type"
  end

  create_table "admin_cohorts", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "project_id"
    t.string "name"
    t.boolean "email_notifications_enabled", default: false
    t.index ["project_id", "name"], name: "index_admin_cohorts_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_admin_cohorts_on_project_id"
  end

  create_table "admin_notice_user_display_statuses", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "last_collapsed_at_time"
    t.boolean "collapsed_status"
    t.index ["user_id"], name: "index_admin_notice_user_display_statuses_on_user_id"
  end

  create_table "admin_project_links", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "project_id"
    t.text "name", size: :medium
    t.text "href", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "link_id"
    t.boolean "pop_out"
    t.integer "position", default: 5
  end

  create_table "admin_project_materials", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "project_id"
    t.integer "material_id"
    t.string "material_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id", "material_type"], name: "admin_proj_mat_mat_idx"
    t.index ["project_id", "material_id", "material_type"], name: "admin_proj_mat_proj_mat_idx"
    t.index ["project_id"], name: "admin_proj_mat_proj_idx"
  end

  create_table "admin_project_users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.boolean "is_admin", default: false
    t.boolean "is_researcher", default: false
    t.index ["project_id", "user_id"], name: "admin_proj_user_uniq_idx", unique: true
    t.index ["project_id"], name: "index_admin_project_users_on_project_id"
    t.index ["user_id"], name: "index_admin_project_users_on_user_id"
  end

  create_table "admin_projects", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "landing_page_slug"
    t.text "landing_page_content", size: :medium
    t.string "project_card_image_url"
    t.string "project_card_description"
    t.boolean "public", default: true
    t.index ["landing_page_slug"], name: "index_admin_projects_on_landing_page_slug", unique: true
  end

  create_table "admin_settings", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.text "description", size: :medium
    t.string "uuid", limit: 36
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "home_page_content", size: :medium
    t.boolean "use_student_security_questions", default: false
    t.boolean "allow_default_class"
    t.boolean "enable_grade_levels", default: false
    t.boolean "use_bitmap_snapshots", default: false
    t.boolean "teachers_can_author", default: true
    t.boolean "enable_member_registration", default: false
    t.boolean "allow_adhoc_schools", default: false
    t.boolean "require_user_consent", default: false
    t.boolean "active"
    t.string "external_url"
    t.text "custom_help_page_html", size: :medium
    t.string "help_type"
    t.boolean "include_external_activities", default: false
    t.text "enabled_bookmark_types", size: :medium
    t.integer "pub_interval", default: 10
    t.boolean "anonymous_can_browse_materials", default: true
    t.boolean "show_collections_menu", default: false
    t.boolean "auto_set_teachers_as_authors", default: false
    t.integer "default_cohort_id"
    t.boolean "wrap_home_page_content", default: true
    t.string "custom_search_path", default: "/search"
    t.string "teacher_home_path", default: "/getting_started"
    t.text "about_page_content", size: :medium
  end

  create_table "admin_site_notice_users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "notice_id"
    t.integer "user_id"
    t.boolean "notice_dismissed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notice_id"], name: "index_admin_site_notice_users_on_notice_id"
    t.index ["user_id"], name: "index_admin_site_notice_users_on_user_id"
  end

  create_table "admin_site_notices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.text "notice_html", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by"
    t.integer "updated_by"
    t.index ["created_by"], name: "index_admin_site_notices_on_created_by"
    t.index ["updated_by"], name: "index_admin_site_notices_on_updated_by"
  end

  create_table "admin_tags", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "scope"
    t.string "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authentications", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "authoring_sites", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "app_id"
    t.string "app_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "site_url"
    t.string "domain_matchers"
    t.string "client_type", default: "confidential"
    t.text "redirect_uris"
  end

  create_table "commons_licenses", id: false, charset: "utf8", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description", size: :medium
    t.string "deed"
    t.string "legal"
    t.string "image"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_commons_licenses_on_code"
  end

  create_table "dataservice_blobs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.binary "content", size: :medium
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 36
    t.string "mimetype"
    t.string "file_extension"
    t.integer "learner_id"
    t.string "checksum"
    t.index ["checksum"], name: "index_dataservice_blobs_on_checksum"
    t.index ["learner_id"], name: "index_dataservice_blobs_on_learner_id"
  end

  create_table "delayed_jobs", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler", size: :long
    t.text "last_error", size: :medium
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "embeddable_iframes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid", limit: 36
    t.string "name"
    t.string "description"
    t.integer "width"
    t.integer "height"
    t.text "url"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "display_in_iframe", default: false
    t.boolean "is_required", default: false
    t.boolean "show_in_featured_question_report", default: true
  end

  create_table "embeddable_image_questions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid", limit: 36
    t.string "name"
    t.text "prompt", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.text "drawing_prompt", size: :medium
    t.boolean "is_required", default: false, null: false
    t.boolean "show_in_featured_question_report", default: true
  end

  create_table "embeddable_multiple_choice_choices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.text "choice", size: :medium
    t.integer "multiple_choice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_correct"
    t.string "external_id"
    t.index ["multiple_choice_id"], name: "index_embeddable_multiple_choice_choices_on_multiple_choice_id"
  end

  create_table "embeddable_multiple_choices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.text "prompt", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_rationale", default: false
    t.text "rationale_prompt", size: :medium
    t.boolean "allow_multiple_selection", default: false
    t.string "external_id"
    t.boolean "is_required", default: false, null: false
    t.boolean "show_in_featured_question_report", default: true
  end

  create_table "embeddable_open_responses", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.text "prompt", size: :medium
    t.string "default_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rows", default: 5
    t.integer "columns", default: 32
    t.integer "font_size", default: 12
    t.string "external_id"
    t.boolean "is_required", default: false, null: false
    t.boolean "show_in_featured_question_report", default: true
  end

  create_table "external_activities", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid"
    t.string "name"
    t.text "archived_description", size: :medium
    t.text "url", size: :medium
    t.string "publication_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "offerings_count", default: 0
    t.string "save_path"
    t.boolean "append_learner_id_to_url"
    t.boolean "popup", default: true
    t.boolean "append_survey_monkey_uid"
    t.integer "template_id"
    t.string "template_type"
    t.string "launch_url"
    t.boolean "is_official", default: false
    t.boolean "student_report_enabled", default: true
    t.string "teacher_guide_url"
    t.string "thumbnail_url"
    t.boolean "is_featured", default: false
    t.boolean "has_pretest", default: false
    t.text "short_description", size: :medium
    t.boolean "allow_collaboration", default: false
    t.string "author_email"
    t.boolean "is_locked"
    t.boolean "logging", default: false
    t.boolean "is_assessment_item", default: false
    t.text "author_url"
    t.text "print_url"
    t.boolean "is_archived", default: false
    t.datetime "archive_date"
    t.string "credits"
    t.string "license_code"
    t.boolean "append_auth_token"
    t.boolean "enable_sharing", default: true
    t.string "material_type", default: "Activity"
    t.string "rubric_url"
    t.boolean "saves_student_data", default: true
    t.text "long_description_for_teacher"
    t.text "long_description"
    t.text "keywords"
    t.integer "tool_id"
    t.boolean "has_teacher_edition", default: false
    t.text "teacher_resources_url"
    t.index ["is_featured", "publication_status"], name: "featured_public"
    t.index ["publication_status"], name: "pub_status"
    t.index ["save_path"], name: "index_external_activities_on_save_path"
    t.index ["template_id", "template_type"], name: "index_external_activities_on_template_id_and_template_type"
    t.index ["user_id"], name: "index_external_activities_on_user_id"
  end

  create_table "external_activity_reports", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "external_activity_id"
    t.integer "external_report_id"
    t.index ["external_activity_id", "external_report_id"], name: "activity_reports_activity_index"
    t.index ["external_report_id"], name: "activity_reports_index"
  end

  create_table "external_reports", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "url"
    t.string "name"
    t.string "launch_text"
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "report_type", default: "offering"
    t.boolean "allowed_for_students", default: false
    t.string "default_report_for_source_type"
    t.boolean "individual_student_reportable", default: false
    t.boolean "individual_activity_reportable", default: false
    t.text "move_students_api_url"
    t.string "move_students_api_token"
    t.boolean "use_query_jwt", default: false
    t.index ["client_id"], name: "index_external_reports_on_client_id"
  end

  create_table "favorites", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "favoritable_id"
    t.string "favoritable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["favoritable_id"], name: "index_favorites_on_favoritable_id"
    t.index ["favoritable_type"], name: "index_favorites_on_favoritable_type"
    t.index ["user_id", "favoritable_id", "favoritable_type"], name: "favorite_unique", unique: true
  end

  create_table "firebase_apps", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "client_email"
    t.text "private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_firebase_apps_on_name"
  end

  create_table "images", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.text "attribution", size: :medium
    t.string "publication_status", default: "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.string "license_code"
    t.integer "width", default: 0
    t.integer "height", default: 0
  end

  create_table "import_duplicate_users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.integer "duplicate_by"
    t.text "data", size: :medium
    t.integer "user_id"
    t.integer "import_id"
  end

  create_table "import_school_district_mappings", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "district_id"
    t.string "import_district_uuid"
  end

  create_table "import_user_school_mappings", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "school_id"
    t.string "import_school_url"
  end

  create_table "imported_users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "user_url"
    t.boolean "is_verified"
    t.integer "user_id"
    t.string "importing_domain"
    t.integer "import_id"
  end

  create_table "imports", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "job_id"
    t.datetime "job_finished_at"
    t.integer "import_type"
    t.integer "progress"
    t.integer "total_imports"
    t.integer "user_id"
    t.text "upload_data", size: :long
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "import_data", size: :long
  end

  create_table "interactives", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description", size: :medium
    t.text "url"
    t.integer "width"
    t.integer "height"
    t.float "scale"
    t.string "image_url"
    t.integer "user_id"
    t.string "credits"
    t.string "publication_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "full_window", default: false
    t.boolean "no_snapshots", default: false
    t.boolean "save_interactive_state", default: false
    t.string "license_code"
    t.integer "external_activity_id"
  end

  create_table "investigations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "teacher_only", default: false
    t.string "publication_status"
    t.integer "offerings_count", default: 0
    t.boolean "student_report_enabled", default: true
    t.boolean "allow_activity_assignment", default: true
    t.boolean "show_score", default: false
    t.string "teacher_guide_url"
    t.string "thumbnail_url"
    t.boolean "is_featured", default: false
    t.text "abstract", size: :medium
    t.string "author_email"
    t.boolean "is_assessment_item", default: false
    t.index ["is_featured", "publication_status"], name: "featured_public"
    t.index ["publication_status"], name: "pub_status"
  end

  create_table "learner_processing_events", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "learner_id"
    t.datetime "portal_end"
    t.datetime "portal_start"
    t.datetime "lara_end"
    t.datetime "lara_start"
    t.integer "elapsed_seconds"
    t.string "duration"
    t.string "login"
    t.string "teacher"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lara_duration"
    t.integer "portal_duration"
    t.index ["learner_id"], name: "index_learner_processing_events_on_learner_id"
    t.index ["url"], name: "index_learner_processing_events_on_url"
  end

  create_table "materials_collection_items", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "materials_collection_id"
    t.string "material_type"
    t.integer "material_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id", "material_type", "position"], name: "material_idx"
    t.index ["materials_collection_id", "position"], name: "materials_collection_idx"
  end

  create_table "materials_collections", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.text "description", size: :medium
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_materials_collections_on_project_id"
  end

  create_table "page_elements", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "page_id"
    t.integer "embeddable_id"
    t.string "embeddable_type"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["embeddable_id", "embeddable_type"], name: "index_page_elements_on_embeddable_id_and_embeddable_type"
    t.index ["embeddable_id"], name: "index_page_elements_on_embeddable_id"
    t.index ["page_id"], name: "index_page_elements_on_page_id"
    t.index ["position"], name: "index_page_elements_on_position"
  end

  create_table "pages", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "section_id"
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "teacher_only", default: false
    t.string "publication_status"
    t.integer "offerings_count", default: 0
    t.text "url"
    t.index ["position"], name: "index_pages_on_position"
    t.index ["section_id", "position"], name: "index_pages_on_section_id_and_position"
  end

  create_table "passwords", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "reset_code"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_passwords_on_user_id"
  end

  create_table "portal_bookmark_visits", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "bookmark_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "portal_bookmarks", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.string "url"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "clazz_id"
    t.boolean "is_visible", default: true, null: false
    t.index ["clazz_id"], name: "index_bookmarks_on_clazz_id"
    t.index ["id", "type"], name: "index_portal_bookmarks_on_id_and_type"
    t.index ["user_id"], name: "index_portal_bookmarks_on_user_id"
  end

  create_table "portal_clazzes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "class_word"
    t.string "status"
    t.integer "course_id"
    t.integer "semester_id"
    t.integer "teacher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "section"
    t.boolean "default_class", default: false
    t.boolean "logging", default: false
    t.string "class_hash", limit: 48
    t.index ["class_word"], name: "index_portal_clazzes_on_class_word", unique: true
  end

  create_table "portal_collaboration_memberships", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "collaboration_id"
    t.integer "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collaboration_id", "student_id"], name: "index_portal_coll_mem_on_collaboration_id_and_student_id"
  end

  create_table "portal_collaborations", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "offering_id"
    t.index ["offering_id"], name: "index_portal_collaborations_on_offering_id"
    t.index ["owner_id"], name: "index_portal_collaborations_on_owner_id"
  end

  create_table "portal_countries", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "formal_name"
    t.string "capital"
    t.string "two_letter", limit: 2
    t.string "three_letter", limit: 3
    t.string "tld"
    t.integer "iso_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iso_id"], name: "index_portal_countries_on_iso_id"
    t.index ["name"], name: "index_portal_countries_on_name"
    t.index ["two_letter"], name: "index_portal_countries_on_two_letter"
  end

  create_table "portal_courses", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.integer "school_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "course_number"
    t.index ["course_number"], name: "index_portal_courses_on_course_number"
    t.index ["name"], name: "index_portal_courses_on_name"
    t.index ["school_id"], name: "index_portal_courses_on_school_id"
  end

  create_table "portal_courses_grade_levels", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "grade_level_id"
    t.integer "course_id"
  end

  create_table "portal_districts", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nces_district_id"
    t.string "state", limit: 2
    t.string "leaid", limit: 7
    t.string "zipcode", limit: 5
    t.index ["nces_district_id"], name: "index_portal_districts_on_nces_district_id"
    t.index ["state"], name: "index_portal_districts_on_state"
  end

  create_table "portal_grade_levels", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "has_grade_levels_id"
    t.string "has_grade_levels_type"
    t.integer "grade_id"
  end

  create_table "portal_grade_levels_teachers", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "grade_level_id"
    t.integer "teacher_id"
  end

  create_table "portal_grades", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "position"
    t.string "uuid"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "portal_learner_activity_feedbacks", id: :integer, charset: "utf8", force: :cascade do |t|
    t.text "text_feedback"
    t.integer "score", default: 0
    t.boolean "has_been_reviewed", default: false
    t.integer "portal_learner_id"
    t.integer "activity_feedback_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "rubric_feedback"
    t.index ["activity_feedback_id"], name: "index_portal_learner_activity_feedbacks_on_activity_feedback_id"
    t.index ["portal_learner_id"], name: "index_portal_learner_activity_feedbacks_on_portal_learner_id"
  end

  create_table "portal_learners", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.integer "student_id"
    t.integer "offering_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "secure_key"
    t.index ["offering_id"], name: "index_portal_learners_on_offering_id"
    t.index ["secure_key"], name: "index_portal_learners_on_sec_key", unique: true
    t.index ["student_id"], name: "index_portal_learners_on_student_id"
  end

  create_table "portal_nces06_districts", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "LEAID", limit: 7
    t.string "FIPST", limit: 2
    t.string "STID", limit: 14
    t.string "NAME", limit: 60
    t.string "PHONE", limit: 10
    t.string "MSTREE", limit: 30
    t.string "MCITY", limit: 30
    t.string "MSTATE", limit: 2
    t.string "MZIP", limit: 5
    t.string "MZIP4", limit: 4
    t.string "LSTREE", limit: 30
    t.string "LCITY", limit: 30
    t.string "LSTATE", limit: 2
    t.string "LZIP", limit: 5
    t.string "LZIP4", limit: 4
    t.string "KIND", limit: 1
    t.string "UNION", limit: 3
    t.string "CONUM", limit: 5
    t.string "CONAME", limit: 30
    t.string "CSA", limit: 3
    t.string "CBSA", limit: 5
    t.string "METMIC", limit: 1
    t.string "MSC", limit: 1
    t.string "ULOCAL", limit: 2
    t.string "CDCODE", limit: 4
    t.float "LATCOD"
    t.float "LONCOD"
    t.string "BOUND", limit: 1
    t.string "GSLO", limit: 2
    t.string "GSHI", limit: 2
    t.string "AGCHRT", limit: 1
    t.integer "SCH"
    t.float "TEACH"
    t.integer "UG"
    t.integer "PK12"
    t.integer "MEMBER"
    t.integer "MIGRNT"
    t.integer "SPECED"
    t.integer "ELL"
    t.float "PKTCH"
    t.float "KGTCH"
    t.float "ELMTCH"
    t.float "SECTCH"
    t.float "UGTCH"
    t.float "TOTTCH"
    t.float "AIDES"
    t.float "CORSUP"
    t.float "ELMGUI"
    t.float "SECGUI"
    t.float "TOTGUI"
    t.float "LIBSPE"
    t.float "LIBSUP"
    t.float "LEAADM"
    t.float "LEASUP"
    t.float "SCHADM"
    t.float "SCHSUP"
    t.float "STUSUP"
    t.float "OTHSUP"
    t.string "IGSLO", limit: 1
    t.string "IGSHI", limit: 1
    t.string "ISCH", limit: 1
    t.string "ITEACH", limit: 1
    t.string "IUG", limit: 1
    t.string "IPK12", limit: 1
    t.string "IMEMB", limit: 1
    t.string "IMIGRN", limit: 1
    t.string "ISPEC", limit: 1
    t.string "IELL", limit: 1
    t.string "IPKTCH", limit: 1
    t.string "IKGTCH", limit: 1
    t.string "IELTCH", limit: 1
    t.string "ISETCH", limit: 1
    t.string "IUGTCH", limit: 1
    t.string "ITOTCH", limit: 1
    t.string "IAIDES", limit: 1
    t.string "ICOSUP", limit: 1
    t.string "IELGUI", limit: 1
    t.string "ISEGUI", limit: 1
    t.string "ITOGUI", limit: 1
    t.string "ILISPE", limit: 1
    t.string "ILISUP", limit: 1
    t.string "ILEADM", limit: 1
    t.string "ILESUP", limit: 1
    t.string "ISCADM", limit: 1
    t.string "ISCSUP", limit: 1
    t.string "ISTSUP", limit: 1
    t.string "IOTSUP", limit: 1
    t.index ["LEAID"], name: "index_portal_nces06_districts_on_LEAID"
    t.index ["NAME"], name: "index_portal_nces06_districts_on_NAME"
    t.index ["STID"], name: "index_portal_nces06_districts_on_STID"
  end

  create_table "portal_nces06_schools", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "nces_district_id"
    t.string "NCESSCH", limit: 12
    t.string "FIPST", limit: 2
    t.string "LEAID", limit: 7
    t.string "SCHNO", limit: 5
    t.string "STID", limit: 14
    t.string "SEASCH", limit: 20
    t.string "LEANM", limit: 60
    t.string "SCHNAM", limit: 50
    t.string "PHONE", limit: 10
    t.string "MSTREE", limit: 30
    t.string "MCITY", limit: 30
    t.string "MSTATE", limit: 2
    t.string "MZIP", limit: 5
    t.string "MZIP4", limit: 4
    t.string "LSTREE", limit: 30
    t.string "LCITY", limit: 30
    t.string "LSTATE", limit: 2
    t.string "LZIP", limit: 5
    t.string "LZIP4", limit: 4
    t.string "KIND", limit: 1
    t.string "STATUS", limit: 1
    t.string "ULOCAL", limit: 2
    t.float "LATCOD"
    t.float "LONCOD"
    t.string "CDCODE", limit: 4
    t.string "CONUM", limit: 5
    t.string "CONAME", limit: 30
    t.float "FTE"
    t.string "GSLO", limit: 2
    t.string "GSHI", limit: 2
    t.string "LEVEL", limit: 1
    t.string "TITLEI", limit: 1
    t.string "STITLI", limit: 1
    t.string "MAGNET", limit: 1
    t.string "CHARTR", limit: 1
    t.string "SHARED", limit: 1
    t.integer "FRELCH"
    t.integer "REDLCH"
    t.integer "TOTFRL"
    t.integer "MIGRNT"
    t.integer "PK"
    t.integer "AMPKM"
    t.integer "AMPKF"
    t.integer "AMPKU"
    t.integer "ASPKM"
    t.integer "ASPKF"
    t.integer "ASPKU"
    t.integer "HIPKM"
    t.integer "HIPKF"
    t.integer "HIPKU"
    t.integer "BLPKM"
    t.integer "BLPKF"
    t.integer "BLPKU"
    t.integer "WHPKM"
    t.integer "WHPKF"
    t.integer "WHPKU"
    t.integer "KG"
    t.integer "AMKGM"
    t.integer "AMKGF"
    t.integer "AMKGU"
    t.integer "ASKGM"
    t.integer "ASKGF"
    t.integer "ASKGU"
    t.integer "HIKGM"
    t.integer "HIKGF"
    t.integer "HIKGU"
    t.integer "BLKGM"
    t.integer "BLKGF"
    t.integer "BLKGU"
    t.integer "WHKGM"
    t.integer "WHKGF"
    t.integer "WHKGU"
    t.integer "G01"
    t.integer "AM01M"
    t.integer "AM01F"
    t.integer "AM01U"
    t.integer "AS01M"
    t.integer "AS01F"
    t.integer "AS01U"
    t.integer "HI01M"
    t.integer "HI01F"
    t.integer "HI01U"
    t.integer "BL01M"
    t.integer "BL01F"
    t.integer "BL01U"
    t.integer "WH01M"
    t.integer "WH01F"
    t.integer "WH01U"
    t.integer "G02"
    t.integer "AM02M"
    t.integer "AM02F"
    t.integer "AM02U"
    t.integer "AS02M"
    t.integer "AS02F"
    t.integer "AS02U"
    t.integer "HI02M"
    t.integer "HI02F"
    t.integer "HI02U"
    t.integer "BL02M"
    t.integer "BL02F"
    t.integer "BL02U"
    t.integer "WH02M"
    t.integer "WH02F"
    t.integer "WH02U"
    t.integer "G03"
    t.integer "AM03M"
    t.integer "AM03F"
    t.integer "AM03U"
    t.integer "AS03M"
    t.integer "AS03F"
    t.integer "AS03U"
    t.integer "HI03M"
    t.integer "HI03F"
    t.integer "HI03U"
    t.integer "BL03M"
    t.integer "BL03F"
    t.integer "BL03U"
    t.integer "WH03M"
    t.integer "WH03F"
    t.integer "WH03U"
    t.integer "G04"
    t.integer "AM04M"
    t.integer "AM04F"
    t.integer "AM04U"
    t.integer "AS04M"
    t.integer "AS04F"
    t.integer "AS04U"
    t.integer "HI04M"
    t.integer "HI04F"
    t.integer "HI04U"
    t.integer "BL04M"
    t.integer "BL04F"
    t.integer "BL04U"
    t.integer "WH04M"
    t.integer "WH04F"
    t.integer "WH04U"
    t.integer "G05"
    t.integer "AM05M"
    t.integer "AM05F"
    t.integer "AM05U"
    t.integer "AS05M"
    t.integer "AS05F"
    t.integer "AS05U"
    t.integer "HI05M"
    t.integer "HI05F"
    t.integer "HI05U"
    t.integer "BL05M"
    t.integer "BL05F"
    t.integer "BL05U"
    t.integer "WH05M"
    t.integer "WH05F"
    t.integer "WH05U"
    t.integer "G06"
    t.integer "AM06M"
    t.integer "AM06F"
    t.integer "AM06U"
    t.integer "AS06M"
    t.integer "AS06F"
    t.integer "AS06U"
    t.integer "HI06M"
    t.integer "HI06F"
    t.integer "HI06U"
    t.integer "BL06M"
    t.integer "BL06F"
    t.integer "BL06U"
    t.integer "WH06M"
    t.integer "WH06F"
    t.integer "WH06U"
    t.integer "G07"
    t.integer "AM07M"
    t.integer "AM07F"
    t.integer "AM07U"
    t.integer "AS07M"
    t.integer "AS07F"
    t.integer "AS07U"
    t.integer "HI07M"
    t.integer "HI07F"
    t.integer "HI07U"
    t.integer "BL07M"
    t.integer "BL07F"
    t.integer "BL07U"
    t.integer "WH07M"
    t.integer "WH07F"
    t.integer "WH07U"
    t.integer "G08"
    t.integer "AM08M"
    t.integer "AM08F"
    t.integer "AM08U"
    t.integer "AS08M"
    t.integer "AS08F"
    t.integer "AS08U"
    t.integer "HI08M"
    t.integer "HI08F"
    t.integer "HI08U"
    t.integer "BL08M"
    t.integer "BL08F"
    t.integer "BL08U"
    t.integer "WH08M"
    t.integer "WH08F"
    t.integer "WH08U"
    t.integer "G09"
    t.integer "AM09M"
    t.integer "AM09F"
    t.integer "AM09U"
    t.integer "AS09M"
    t.integer "AS09F"
    t.integer "AS09U"
    t.integer "HI09M"
    t.integer "HI09F"
    t.integer "HI09U"
    t.integer "BL09M"
    t.integer "BL09F"
    t.integer "BL09U"
    t.integer "WH09M"
    t.integer "WH09F"
    t.integer "WH09U"
    t.integer "G10"
    t.integer "AM10M"
    t.integer "AM10F"
    t.integer "AM10U"
    t.integer "AS10M"
    t.integer "AS10F"
    t.integer "AS10U"
    t.integer "HI10M"
    t.integer "HI10F"
    t.integer "HI10U"
    t.integer "BL10M"
    t.integer "BL10F"
    t.integer "BL10U"
    t.integer "WH10M"
    t.integer "WH10F"
    t.integer "WH10U"
    t.integer "G11"
    t.integer "AM11M"
    t.integer "AM11F"
    t.integer "AM11U"
    t.integer "AS11M"
    t.integer "AS11F"
    t.integer "AS11U"
    t.integer "HI11M"
    t.integer "HI11F"
    t.integer "HI11U"
    t.integer "BL11M"
    t.integer "BL11F"
    t.integer "BL11U"
    t.integer "WH11M"
    t.integer "WH11F"
    t.integer "WH11U"
    t.integer "G12"
    t.integer "AM12M"
    t.integer "AM12F"
    t.integer "AM12U"
    t.integer "AS12M"
    t.integer "AS12F"
    t.integer "AS12U"
    t.integer "HI12M"
    t.integer "HI12F"
    t.integer "HI12U"
    t.integer "BL12M"
    t.integer "BL12F"
    t.integer "BL12U"
    t.integer "WH12M"
    t.integer "WH12F"
    t.integer "WH12U"
    t.integer "UG"
    t.integer "AMUGM"
    t.integer "AMUGF"
    t.integer "AMUGU"
    t.integer "ASUGM"
    t.integer "ASUGF"
    t.integer "ASUGU"
    t.integer "HIUGM"
    t.integer "HIUGF"
    t.integer "HIUGU"
    t.integer "BLUGM"
    t.integer "BLUGF"
    t.integer "BLUGU"
    t.integer "WHUGM"
    t.integer "WHUGF"
    t.integer "WHUGU"
    t.integer "MEMBER"
    t.integer "AM"
    t.integer "AMALM"
    t.integer "AMALF"
    t.integer "AMALU"
    t.integer "ASIAN"
    t.integer "ASALM"
    t.integer "ASALF"
    t.integer "ASALU"
    t.integer "HISP"
    t.integer "HIALM"
    t.integer "HIALF"
    t.integer "HIALU"
    t.integer "BLACK"
    t.integer "BLALM"
    t.integer "BLALF"
    t.integer "BLALU"
    t.integer "WHITE"
    t.integer "WHALM"
    t.integer "WHALF"
    t.integer "WHALU"
    t.integer "TOTETH"
    t.float "PUPTCH"
    t.integer "TOTGRD"
    t.string "IFTE", limit: 1
    t.string "IGSLO", limit: 1
    t.string "IGSHI", limit: 1
    t.string "ITITLI", limit: 1
    t.string "ISTITL", limit: 1
    t.string "IMAGNE", limit: 1
    t.string "ICHART", limit: 1
    t.string "ISHARE", limit: 1
    t.string "IFRELC", limit: 1
    t.string "IREDLC", limit: 1
    t.string "ITOTFR", limit: 1
    t.string "IMIGRN", limit: 1
    t.string "IPK", limit: 1
    t.string "IAMPKM", limit: 1
    t.string "IAMPKF", limit: 1
    t.string "IAMPKU", limit: 1
    t.string "IASPKM", limit: 1
    t.string "IASPKF", limit: 1
    t.string "IASPKU", limit: 1
    t.string "IHIPKM", limit: 1
    t.string "IHIPKF", limit: 1
    t.string "IHIPKU", limit: 1
    t.string "IBLPKM", limit: 1
    t.string "IBLPKF", limit: 1
    t.string "IBLPKU", limit: 1
    t.string "IWHPKM", limit: 1
    t.string "IWHPKF", limit: 1
    t.string "IWHPKU", limit: 1
    t.string "IKG", limit: 1
    t.string "IAMKGM", limit: 1
    t.string "IAMKGF", limit: 1
    t.string "IAMKGU", limit: 1
    t.string "IASKGM", limit: 1
    t.string "IASKGF", limit: 1
    t.string "IASKGU", limit: 1
    t.string "IHIKGM", limit: 1
    t.string "IHIKGF", limit: 1
    t.string "IHIKGU", limit: 1
    t.string "IBLKGM", limit: 1
    t.string "IBLKGF", limit: 1
    t.string "IBLKGU", limit: 1
    t.string "IWHKGM", limit: 1
    t.string "IWHKGF", limit: 1
    t.string "IWHKGU", limit: 1
    t.string "IG01", limit: 1
    t.string "IAM01M", limit: 1
    t.string "IAM01F", limit: 1
    t.string "IAM01U", limit: 1
    t.string "IAS01M", limit: 1
    t.string "IAS01F", limit: 1
    t.string "IAS01U", limit: 1
    t.string "IHI01M", limit: 1
    t.string "IHI01F", limit: 1
    t.string "IHI01U", limit: 1
    t.string "IBL01M", limit: 1
    t.string "IBL01F", limit: 1
    t.string "IBL01U", limit: 1
    t.string "IWH01M", limit: 1
    t.string "IWH01F", limit: 1
    t.string "IWH01U", limit: 1
    t.string "IG02", limit: 1
    t.string "IAM02M", limit: 1
    t.string "IAM02F", limit: 1
    t.string "IAM02U", limit: 1
    t.string "IAS02M", limit: 1
    t.string "IAS02F", limit: 1
    t.string "IAS02U", limit: 1
    t.string "IHI02M", limit: 1
    t.string "IHI02F", limit: 1
    t.string "IHI02U", limit: 1
    t.string "IBL02M", limit: 1
    t.string "IBL02F", limit: 1
    t.string "IBL02U", limit: 1
    t.string "IWH02M", limit: 1
    t.string "IWH02F", limit: 1
    t.string "IWH02U", limit: 1
    t.string "IG03", limit: 1
    t.string "IAM03M", limit: 1
    t.string "IAM03F", limit: 1
    t.string "IAM03U", limit: 1
    t.string "IAS03M", limit: 1
    t.string "IAS03F", limit: 1
    t.string "IAS03U", limit: 1
    t.string "IHI03M", limit: 1
    t.string "IHI03F", limit: 1
    t.string "IHI03U", limit: 1
    t.string "IBL03M", limit: 1
    t.string "IBL03F", limit: 1
    t.string "IBL03U", limit: 1
    t.string "IWH03M", limit: 1
    t.string "IWH03F", limit: 1
    t.string "IWH03U", limit: 1
    t.string "IG04", limit: 1
    t.string "IAM04M", limit: 1
    t.string "IAM04F", limit: 1
    t.string "IAM04U", limit: 1
    t.string "IAS04M", limit: 1
    t.string "IAS04F", limit: 1
    t.string "IAS04U", limit: 1
    t.string "IHI04M", limit: 1
    t.string "IHI04F", limit: 1
    t.string "IHI04U", limit: 1
    t.string "IBL04M", limit: 1
    t.string "IBL04F", limit: 1
    t.string "IBL04U", limit: 1
    t.string "IWH04M", limit: 1
    t.string "IWH04F", limit: 1
    t.string "IWH04U", limit: 1
    t.string "IG05", limit: 1
    t.string "IAM05M", limit: 1
    t.string "IAM05F", limit: 1
    t.string "IAM05U", limit: 1
    t.string "IAS05M", limit: 1
    t.string "IAS05F", limit: 1
    t.string "IAS05U", limit: 1
    t.string "IHI05M", limit: 1
    t.string "IHI05F", limit: 1
    t.string "IHI05U", limit: 1
    t.string "IBL05M", limit: 1
    t.string "IBL05F", limit: 1
    t.string "IBL05U", limit: 1
    t.string "IWH05M", limit: 1
    t.string "IWH05F", limit: 1
    t.string "IWH05U", limit: 1
    t.string "IG06", limit: 1
    t.string "IAM06M", limit: 1
    t.string "IAM06F", limit: 1
    t.string "IAM06U", limit: 1
    t.string "IAS06M", limit: 1
    t.string "IAS06F", limit: 1
    t.string "IAS06U", limit: 1
    t.string "IHI06M", limit: 1
    t.string "IHI06F", limit: 1
    t.string "IHI06U", limit: 1
    t.string "IBL06M", limit: 1
    t.string "IBL06F", limit: 1
    t.string "IBL06U", limit: 1
    t.string "IWH06M", limit: 1
    t.string "IWH06F", limit: 1
    t.string "IWH06U", limit: 1
    t.string "IG07", limit: 1
    t.string "IAM07M", limit: 1
    t.string "IAM07F", limit: 1
    t.string "IAM07U", limit: 1
    t.string "IAS07M", limit: 1
    t.string "IAS07F", limit: 1
    t.string "IAS07U", limit: 1
    t.string "IHI07M", limit: 1
    t.string "IHI07F", limit: 1
    t.string "IHI07U", limit: 1
    t.string "IBL07M", limit: 1
    t.string "IBL07F", limit: 1
    t.string "IBL07U", limit: 1
    t.string "IWH07M", limit: 1
    t.string "IWH07F", limit: 1
    t.string "IWH07U", limit: 1
    t.string "IG08", limit: 1
    t.string "IAM08M", limit: 1
    t.string "IAM08F", limit: 1
    t.string "IAM08U", limit: 1
    t.string "IAS08M", limit: 1
    t.string "IAS08F", limit: 1
    t.string "IAS08U", limit: 1
    t.string "IHI08M", limit: 1
    t.string "IHI08F", limit: 1
    t.string "IHI08U", limit: 1
    t.string "IBL08M", limit: 1
    t.string "IBL08F", limit: 1
    t.string "IBL08U", limit: 1
    t.string "IWH08M", limit: 1
    t.string "IWH08F", limit: 1
    t.string "IWH08U", limit: 1
    t.string "IG09", limit: 1
    t.string "IAM09M", limit: 1
    t.string "IAM09F", limit: 1
    t.string "IAM09U", limit: 1
    t.string "IAS09M", limit: 1
    t.string "IAS09F", limit: 1
    t.string "IAS09U", limit: 1
    t.string "IHI09M", limit: 1
    t.string "IHI09F", limit: 1
    t.string "IHI09U", limit: 1
    t.string "IBL09M", limit: 1
    t.string "IBL09F", limit: 1
    t.string "IBL09U", limit: 1
    t.string "IWH09M", limit: 1
    t.string "IWH09F", limit: 1
    t.string "IWH09U", limit: 1
    t.string "IG10", limit: 1
    t.string "IAM10M", limit: 1
    t.string "IAM10F", limit: 1
    t.string "IAM10U", limit: 1
    t.string "IAS10M", limit: 1
    t.string "IAS10F", limit: 1
    t.string "IAS10U", limit: 1
    t.string "IHI10M", limit: 1
    t.string "IHI10F", limit: 1
    t.string "IHI10U", limit: 1
    t.string "IBL10M", limit: 1
    t.string "IBL10F", limit: 1
    t.string "IBL10U", limit: 1
    t.string "IWH10M", limit: 1
    t.string "IWH10F", limit: 1
    t.string "IWH10U", limit: 1
    t.string "IG11", limit: 1
    t.string "IAM11M", limit: 1
    t.string "IAM11F", limit: 1
    t.string "IAM11U", limit: 1
    t.string "IAS11M", limit: 1
    t.string "IAS11F", limit: 1
    t.string "IAS11U", limit: 1
    t.string "IHI11M", limit: 1
    t.string "IHI11F", limit: 1
    t.string "IHI11U", limit: 1
    t.string "IBL11M", limit: 1
    t.string "IBL11F", limit: 1
    t.string "IBL11U", limit: 1
    t.string "IWH11M", limit: 1
    t.string "IWH11F", limit: 1
    t.string "IWH11U", limit: 1
    t.string "IG12", limit: 1
    t.string "IAM12M", limit: 1
    t.string "IAM12F", limit: 1
    t.string "IAM12U", limit: 1
    t.string "IAS12M", limit: 1
    t.string "IAS12F", limit: 1
    t.string "IAS12U", limit: 1
    t.string "IHI12M", limit: 1
    t.string "IHI12F", limit: 1
    t.string "IHI12U", limit: 1
    t.string "IBL12M", limit: 1
    t.string "IBL12F", limit: 1
    t.string "IBL12U", limit: 1
    t.string "IWH12M", limit: 1
    t.string "IWH12F", limit: 1
    t.string "IWH12U", limit: 1
    t.string "IUG", limit: 1
    t.string "IAMUGM", limit: 1
    t.string "IAMUGF", limit: 1
    t.string "IAMUGU", limit: 1
    t.string "IASUGM", limit: 1
    t.string "IASUGF", limit: 1
    t.string "IASUGU", limit: 1
    t.string "IHIUGM", limit: 1
    t.string "IHIUGF", limit: 1
    t.string "IHIUGU", limit: 1
    t.string "IBLUGM", limit: 1
    t.string "IBLUGF", limit: 1
    t.string "IBLUGU", limit: 1
    t.string "IWHUGM", limit: 1
    t.string "IWHUGF", limit: 1
    t.string "IWHUGU", limit: 1
    t.string "IMEMB", limit: 1
    t.string "IAM", limit: 1
    t.string "IAMALM", limit: 1
    t.string "IAMALF", limit: 1
    t.string "IAMALU", limit: 1
    t.string "IASIAN", limit: 1
    t.string "IASALM", limit: 1
    t.string "IASALF", limit: 1
    t.string "IASALU", limit: 1
    t.string "IHISP", limit: 1
    t.string "IHIALM", limit: 1
    t.string "IHIALF", limit: 1
    t.string "IHIALU", limit: 1
    t.string "IBLACK", limit: 1
    t.string "IBLALM", limit: 1
    t.string "IBLALF", limit: 1
    t.string "IBLALU", limit: 1
    t.string "IWHITE", limit: 1
    t.string "IWHALM", limit: 1
    t.string "IWHALF", limit: 1
    t.string "IWHALU", limit: 1
    t.string "IETH", limit: 1
    t.string "IPUTCH", limit: 1
    t.string "ITOTGR", limit: 1
    t.index ["NCESSCH"], name: "index_portal_nces06_schools_on_NCESSCH"
    t.index ["SCHNAM"], name: "index_portal_nces06_schools_on_SCHNAM"
    t.index ["SEASCH"], name: "index_portal_nces06_schools_on_SEASCH"
    t.index ["STID"], name: "index_portal_nces06_schools_on_STID"
    t.index ["nces_district_id"], name: "index_portal_nces06_schools_on_nces_district_id"
  end

  create_table "portal_offering_activity_feedbacks", id: :integer, charset: "utf8", force: :cascade do |t|
    t.boolean "enable_text_feedback", default: false
    t.integer "max_score", default: 10
    t.string "score_type", default: "none"
    t.integer "activity_id"
    t.integer "portal_offering_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "use_rubric"
    t.text "rubric"
  end

  create_table "portal_offering_embeddable_metadata", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "embeddable_id"
    t.string "embeddable_type"
    t.boolean "enable_score", default: false
    t.integer "max_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_text_feedback", default: false
    t.index ["offering_id", "embeddable_id", "embeddable_type"], name: "index_portal_offering_metadata", unique: true
  end

  create_table "portal_offerings", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "status"
    t.integer "clazz_id"
    t.integer "runnable_id"
    t.string "runnable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.boolean "default_offering", default: false
    t.integer "position", default: 0
    t.boolean "anonymous_report", default: false
    t.boolean "locked", default: false
    t.index ["clazz_id"], name: "index_portal_offerings_on_clazz_id"
    t.index ["runnable_id"], name: "index_portal_offerings_on_runnable_id"
    t.index ["runnable_type"], name: "index_portal_offerings_on_runnable_type"
  end

  create_table "portal_permission_forms", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
  end

  create_table "portal_school_memberships", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "member_id"
    t.string "member_type"
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_type", "member_id"], name: "member_type_id_index"
    t.index ["school_id", "member_id", "member_type"], name: "school_memberships_long_idx"
  end

  create_table "portal_schools", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.integer "district_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nces_school_id"
    t.string "state", limit: 80
    t.string "zipcode", limit: 20
    t.string "ncessch", limit: 12
    t.integer "country_id"
    t.text "city", size: :medium
    t.index ["country_id"], name: "index_portal_schools_on_country_id"
    t.index ["district_id"], name: "index_portal_schools_on_district_id"
    t.index ["name"], name: "index_portal_schools_on_name"
    t.index ["nces_school_id"], name: "index_portal_schools_on_nces_school_id"
    t.index ["state"], name: "index_portal_schools_on_state"
  end

  create_table "portal_student_clazzes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "clazz_id"
    t.integer "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clazz_id"], name: "index_portal_student_clazzes_on_clazz_id"
    t.index ["student_id", "clazz_id"], name: "student_class_index"
  end

  create_table "portal_student_permission_forms", id: :integer, charset: "utf8", force: :cascade do |t|
    t.boolean "signed"
    t.integer "portal_student_id"
    t.integer "portal_permission_form_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portal_permission_form_id"], name: "p_s_p_form_id"
    t.index ["portal_student_id"], name: "index_portal_student_permission_forms_on_portal_student_id"
  end

  create_table "portal_students", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.integer "user_id"
    t.integer "grade_level_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_portal_students_on_user_id"
  end

  create_table "portal_subjects", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.integer "teacher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "portal_teacher_clazzes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "clazz_id"
    t.integer "teacher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.integer "position", default: 0
    t.index ["clazz_id"], name: "index_portal_teacher_clazzes_on_clazz_id"
    t.index ["teacher_id"], name: "index_portal_teacher_clazzes_on_teacher_id"
  end

  create_table "portal_teacher_full_status", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "teacher_id"
    t.boolean "offering_collapsed"
    t.index ["offering_id"], name: "index_portal_teacher_full_status_on_offering_id"
    t.index ["teacher_id"], name: "index_portal_teacher_full_status_on_teacher_id"
  end

  create_table "portal_teachers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "offerings_count", default: 0
    t.integer "left_pane_submenu_item"
    t.index ["user_id"], name: "index_portal_teachers_on_user_id"
  end

  create_table "report_embeddable_filters", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.text "embeddables", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ignore"
    t.index ["offering_id"], name: "index_report_embeddable_filters_on_offering_id"
  end

  create_table "report_learner_activity", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "learner_id"
    t.integer "activity_id"
    t.float "complete_percent"
    t.index ["activity_id"], name: "index_report_learner_activity_on_activity_id"
    t.index ["learner_id"], name: "index_report_learner_activity_on_learner_id"
  end

  create_table "report_learners", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "learner_id"
    t.integer "student_id"
    t.integer "user_id"
    t.integer "offering_id"
    t.integer "class_id"
    t.datetime "last_run"
    t.datetime "last_report"
    t.string "offering_name"
    t.string "teachers_name"
    t.string "student_name"
    t.string "username"
    t.string "school_name"
    t.string "class_name"
    t.integer "runnable_id"
    t.string "runnable_name"
    t.integer "school_id"
    t.integer "num_answerables"
    t.integer "num_answered"
    t.integer "num_correct"
    t.text "answers", size: :long
    t.string "runnable_type"
    t.float "complete_percent"
    t.text "permission_forms", size: :medium
    t.integer "num_submitted"
    t.string "teachers_district"
    t.string "teachers_state"
    t.string "teachers_email"
    t.string "permission_forms_id"
    t.string "teachers_id"
    t.text "teachers_map"
    t.text "permission_forms_map"
    t.index ["class_id"], name: "index_report_learners_on_class_id"
    t.index ["last_run"], name: "index_report_learners_on_last_run"
    t.index ["learner_id"], name: "index_report_learners_on_learner_id"
    t.index ["offering_id"], name: "index_report_learners_on_offering_id"
    t.index ["runnable_id", "runnable_type"], name: "index_report_learners_on_runnable_id_and_runnable_type"
    t.index ["runnable_id"], name: "index_report_learners_on_runnable_id"
    t.index ["school_id"], name: "index_report_learners_on_school_id"
    t.index ["student_id"], name: "index_report_learners_on_student_id"
  end

  create_table "roles", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.integer "position"
    t.string "uuid", limit: 36
  end

  create_table "roles_users", id: false, charset: "utf8", force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id"
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id"
  end

  create_table "saveable_external_link_urls", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "external_link_id"
    t.integer "position"
    t.text "url"
    t.boolean "is_final"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "feedback"
    t.boolean "has_been_reviewed", default: false
    t.integer "score"
    t.index ["external_link_id"], name: "index_saveable_external_link_urls_on_external_link_id"
  end

  create_table "saveable_external_links", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "embeddable_id"
    t.string "embeddable_type"
    t.integer "learner_id"
    t.integer "offering_id"
    t.integer "response_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["embeddable_id", "embeddable_type"], name: "svbl_xtrn_links_poly"
    t.index ["learner_id"], name: "index_saveable_external_links_on_learner_id"
    t.index ["offering_id"], name: "index_saveable_external_links_on_offering_id"
  end

  create_table "saveable_image_question_answers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "image_question_id"
    t.integer "blob_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "note", size: :medium
    t.string "uuid", limit: 36
    t.boolean "is_final"
    t.text "feedback"
    t.boolean "has_been_reviewed", default: false
    t.integer "score"
    t.index ["image_question_id", "position"], name: "i_q_id_and_position_index"
  end

  create_table "saveable_image_questions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "learner_id"
    t.integer "offering_id"
    t.integer "image_question_id"
    t.integer "response_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 36
    t.index ["image_question_id"], name: "index_saveable_image_questions_on_image_question_id"
    t.index ["learner_id"], name: "index_saveable_image_questions_on_learner_id"
    t.index ["offering_id"], name: "index_saveable_image_questions_on_offering_id"
  end

  create_table "saveable_interactive_states", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "interactive_id"
    t.integer "position"
    t.text "state", size: :long
    t.boolean "is_final"
    t.text "feedback"
    t.boolean "has_been_reviewed", default: false
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interactive_id", "position"], name: "inter_id_and_position_index"
  end

  create_table "saveable_interactives", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "learner_id"
    t.integer "offering_id"
    t.integer "response_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "iframe_id"
  end

  create_table "saveable_multiple_choice_answers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "multiple_choice_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 36
    t.boolean "is_final"
    t.text "feedback"
    t.boolean "has_been_reviewed", default: false
    t.integer "score"
    t.index ["multiple_choice_id", "position"], name: "m_c_id_and_position_index"
  end

  create_table "saveable_multiple_choice_rationale_choices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "choice_id"
    t.integer "answer_id"
    t.string "rationale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 36
    t.index ["answer_id"], name: "index_saveable_multiple_choice_rationale_choices_on_answer_id"
    t.index ["choice_id"], name: "index_saveable_multiple_choice_rationale_choices_on_choice_id"
  end

  create_table "saveable_multiple_choices", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "learner_id"
    t.integer "multiple_choice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "offering_id"
    t.integer "response_count", default: 0
    t.string "uuid", limit: 36
    t.index ["learner_id"], name: "index_saveable_multiple_choices_on_learner_id"
    t.index ["multiple_choice_id"], name: "index_saveable_multiple_choices_on_multiple_choice_id"
    t.index ["offering_id"], name: "index_saveable_multiple_choices_on_offering_id"
  end

  create_table "saveable_open_response_answers", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "open_response_id"
    t.integer "position"
    t.text "answer", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_final"
    t.text "feedback"
    t.boolean "has_been_reviewed", default: false
    t.integer "score"
    t.index ["open_response_id", "position"], name: "o_r_id_and_position_index"
  end

  create_table "saveable_open_responses", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "learner_id"
    t.integer "open_response_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "offering_id"
    t.integer "response_count", default: 0
    t.index ["learner_id"], name: "index_saveable_open_responses_on_learner_id"
    t.index ["offering_id"], name: "index_saveable_open_responses_on_offering_id"
    t.index ["open_response_id"], name: "index_saveable_open_responses_on_open_response_id"
  end

  create_table "saveable_sparks_measuring_resistance", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "learner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "offering_id"
    t.index ["learner_id"], name: "index_saveable_sparks_measuring_resistance_on_learner_id"
    t.index ["offering_id"], name: "index_saveable_sparks_measuring_resistance_on_offering_id"
  end

  create_table "saveable_sparks_measuring_resistance_reports", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "measuring_resistance_id"
    t.integer "position"
    t.text "content", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "activity_id"
    t.string "uuid", limit: 36
    t.string "name"
    t.text "description", size: :medium
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "teacher_only", default: false
    t.string "publication_status"
    t.index ["activity_id", "position"], name: "index_sections_on_activity_id_and_position"
    t.index ["position"], name: "index_sections_on_position"
  end

  create_table "security_questions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "question", limit: 100, null: false
    t.string "answer", limit: 100, null: false
    t.index ["user_id"], name: "index_security_questions_on_user_id"
  end

  create_table "sessions", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "standard_documents", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uri"
    t.string "jurisdiction"
    t.string "title"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_standard_documents_on_name", unique: true
  end

  create_table "standard_statements", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "uri"
    t.string "doc"
    t.string "statement_notation"
    t.string "statement_label"
    t.text "description"
    t.text "parents"
    t.string "material_type"
    t.integer "material_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "education_level"
    t.boolean "is_leaf"
    t.index ["uri", "material_type", "material_id"], name: "standard_unique", unique: true
  end

  create_table "taggings", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "taggable_type"
    t.string "context"
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "teacher_project_views", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "viewed_project_id", null: false
    t.integer "teacher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["teacher_id"], name: "index_teacher_project_views_on_teacher_id"
  end

  create_table "tools", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "source_type"
    t.text "tool_id"
    t.string "remote_duplicate_url"
  end

  create_table "users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "login", limit: 40
    t.string "first_name", limit: 100, default: ""
    t.string "last_name", limit: 100, default: ""
    t.string "email", limit: 128, default: "", null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "password_salt", default: "", null: false
    t.string "remember_token"
    t.string "confirmation_token"
    t.string "state", default: "passive", null: false
    t.datetime "remember_created_at"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.string "uuid", limit: 36
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default_user", default: false
    t.boolean "site_admin", default: false
    t.string "external_id"
    t.boolean "require_password_reset", default: false
    t.boolean "of_consenting_age", default: false
    t.boolean "have_consent", default: false
    t.boolean "asked_age", default: false
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "unconfirmed_email"
    t.datetime "confirmation_sent_at"
    t.boolean "require_portal_user_type", default: false
    t.string "sign_up_path"
    t.boolean "email_subscribed", default: false
    t.boolean "can_add_teachers_to_cohorts", default: false
    t.datetime "reset_password_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["id"], name: "index_users_on_id_and_type"
    t.index ["login"], name: "index_users_on_login", unique: true
  end

end
