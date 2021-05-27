# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210520131514) do

  create_table "access_grants", force: :cascade do |t|
    t.string   "code",                    limit: 255
    t.string   "access_token",            limit: 255
    t.string   "refresh_token",           limit: 255
    t.datetime "access_token_expires_at"
    t.integer  "user_id",                 limit: 4
    t.integer  "client_id",               limit: 4
    t.string   "state",                   limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "learner_id",              limit: 4
    t.integer  "teacher_id",              limit: 4
  end

  add_index "access_grants", ["client_id"], name: "index_access_grants_on_client_id", using: :btree
  add_index "access_grants", ["learner_id"], name: "index_access_grants_on_learner_id", using: :btree
  add_index "access_grants", ["teacher_id"], name: "index_access_grants_on_teacher_id", using: :btree
  add_index "access_grants", ["user_id"], name: "index_access_grants_on_user_id", using: :btree

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.string   "uuid",                   limit: 36
    t.string   "name",                   limit: 255
    t.text     "description",            limit: 16777215
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "position",               limit: 4
    t.integer  "investigation_id",       limit: 4
    t.integer  "original_id",            limit: 4
    t.boolean  "teacher_only",                            default: false
    t.string   "publication_status",     limit: 255
    t.integer  "offerings_count",        limit: 4,        default: 0
    t.boolean  "student_report_enabled",                  default: true
    t.boolean  "show_score",                              default: false
    t.string   "teacher_guide_url",      limit: 255
    t.string   "thumbnail_url",          limit: 255
    t.boolean  "is_featured",                             default: false
    t.boolean  "is_assessment_item",                      default: false
  end

  add_index "activities", ["investigation_id", "position"], name: "index_activities_on_investigation_id_and_position", using: :btree
  add_index "activities", ["is_featured", "publication_status"], name: "featured_public", using: :btree
  add_index "activities", ["publication_status"], name: "pub_status", using: :btree

  create_table "admin_cohort_items", force: :cascade do |t|
    t.integer "admin_cohort_id", limit: 4
    t.integer "item_id",         limit: 4
    t.string  "item_type",       limit: 255
  end

  add_index "admin_cohort_items", ["admin_cohort_id"], name: "index_admin_cohort_items_on_admin_cohort_id", using: :btree
  add_index "admin_cohort_items", ["item_id"], name: "index_admin_cohort_items_on_item_id", using: :btree
  add_index "admin_cohort_items", ["item_type"], name: "index_admin_cohort_items_on_item_type", using: :btree

  create_table "admin_cohorts", force: :cascade do |t|
    t.integer "project_id",                  limit: 4
    t.string  "name",                        limit: 255
    t.boolean "email_notifications_enabled",             default: false
  end

  add_index "admin_cohorts", ["project_id", "name"], name: "index_admin_cohorts_on_project_id_and_name", unique: true, using: :btree
  add_index "admin_cohorts", ["project_id"], name: "index_admin_cohorts_on_project_id", using: :btree

  create_table "admin_notice_user_display_statuses", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.datetime "last_collapsed_at_time"
    t.boolean  "collapsed_status"
  end

  add_index "admin_notice_user_display_statuses", ["user_id"], name: "index_admin_notice_user_display_statuses_on_user_id", using: :btree

  create_table "admin_project_links", force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.text     "name",       limit: 16777215
    t.text     "href",       limit: 16777215
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "link_id",    limit: 255
    t.boolean  "pop_out"
    t.integer  "position",   limit: 4,        default: 5
  end

  create_table "admin_project_materials", force: :cascade do |t|
    t.integer  "project_id",    limit: 4
    t.integer  "material_id",   limit: 4
    t.string   "material_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "admin_project_materials", ["material_id", "material_type"], name: "admin_proj_mat_mat_idx", using: :btree
  add_index "admin_project_materials", ["project_id", "material_id", "material_type"], name: "admin_proj_mat_proj_mat_idx", using: :btree
  add_index "admin_project_materials", ["project_id"], name: "admin_proj_mat_proj_idx", using: :btree

  create_table "admin_project_users", force: :cascade do |t|
    t.integer "project_id",    limit: 4
    t.integer "user_id",       limit: 4
    t.boolean "is_admin",                default: false
    t.boolean "is_researcher",           default: false
  end

  add_index "admin_project_users", ["project_id", "user_id"], name: "admin_proj_user_uniq_idx", unique: true, using: :btree
  add_index "admin_project_users", ["project_id"], name: "index_admin_project_users_on_project_id", using: :btree
  add_index "admin_project_users", ["user_id"], name: "index_admin_project_users_on_user_id", using: :btree

  create_table "admin_projects", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "landing_page_slug",        limit: 255
    t.text     "landing_page_content",     limit: 16777215
    t.string   "project_card_image_url",   limit: 255
    t.string   "project_card_description", limit: 255
    t.boolean  "public",                                    default: true
  end

  add_index "admin_projects", ["landing_page_slug"], name: "index_admin_projects_on_landing_page_slug", unique: true, using: :btree

  create_table "admin_settings", force: :cascade do |t|
    t.integer  "user_id",                        limit: 4
    t.text     "description",                    limit: 16777215
    t.string   "uuid",                           limit: 36
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.text     "home_page_content",              limit: 16777215
    t.boolean  "use_student_security_questions",                  default: false
    t.boolean  "allow_default_class"
    t.boolean  "enable_grade_levels",                             default: false
    t.boolean  "use_bitmap_snapshots",                            default: false
    t.boolean  "teachers_can_author",                             default: true
    t.boolean  "enable_member_registration",                      default: false
    t.boolean  "allow_adhoc_schools",                             default: false
    t.boolean  "require_user_consent",                            default: false
    t.boolean  "use_periodic_bundle_uploading",                   default: false
    t.string   "jnlp_cdn_hostname",              limit: 255
    t.boolean  "active"
    t.string   "external_url",                   limit: 255
    t.text     "custom_help_page_html",          limit: 16777215
    t.string   "help_type",                      limit: 255
    t.boolean  "include_external_activities",                     default: false
    t.text     "enabled_bookmark_types",         limit: 16777215
    t.integer  "pub_interval",                   limit: 4,        default: 10
    t.boolean  "anonymous_can_browse_materials",                  default: true
    t.string   "jnlp_url",                       limit: 255
    t.boolean  "show_collections_menu",                           default: false
    t.boolean  "auto_set_teachers_as_authors",                    default: false
    t.integer  "default_cohort_id",              limit: 4
    t.boolean  "wrap_home_page_content",                          default: true
    t.string   "custom_search_path",             limit: 255,      default: "/search"
    t.string   "teacher_home_path",              limit: 255,      default: "/getting_started"
    t.text     "about_page_content",             limit: 16777215
  end

  create_table "admin_site_notice_users", force: :cascade do |t|
    t.integer  "notice_id",        limit: 4
    t.integer  "user_id",          limit: 4
    t.boolean  "notice_dismissed"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "admin_site_notice_users", ["notice_id"], name: "index_admin_site_notice_users_on_notice_id", using: :btree
  add_index "admin_site_notice_users", ["user_id"], name: "index_admin_site_notice_users_on_user_id", using: :btree

  create_table "admin_site_notices", force: :cascade do |t|
    t.text     "notice_html", limit: 16777215
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "created_by",  limit: 4
    t.integer  "updated_by",  limit: 4
  end

  add_index "admin_site_notices", ["created_by"], name: "index_admin_site_notices_on_created_by", using: :btree
  add_index "admin_site_notices", ["updated_by"], name: "index_admin_site_notices_on_updated_by", using: :btree

  create_table "admin_tags", force: :cascade do |t|
    t.string   "scope",      limit: 255
    t.string   "tag",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "provider",   limit: 255
    t.string   "uid",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "authoring_sites", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "app_id",          limit: 255
    t.string   "app_secret",      limit: 255
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "site_url",        limit: 255
    t.string   "domain_matchers", limit: 255
    t.string   "client_type",     limit: 255,   default: "confidential"
    t.text     "redirect_uris",   limit: 65535
  end

  create_table "commons_licenses", id: false, force: :cascade do |t|
    t.string   "code",        limit: 255,      null: false
    t.string   "name",        limit: 255,      null: false
    t.text     "description", limit: 16777215
    t.string   "deed",        limit: 255
    t.string   "legal",       limit: 255
    t.string   "image",       limit: 255
    t.integer  "number",      limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "commons_licenses", ["code"], name: "index_commons_licenses_on_code", using: :btree

  create_table "dataservice_blobs", force: :cascade do |t|
    t.binary   "content",                    limit: 16777215
    t.string   "token",                      limit: 255
    t.integer  "bundle_content_id",          limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "periodic_bundle_content_id", limit: 4
    t.string   "uuid",                       limit: 36
    t.string   "mimetype",                   limit: 255
    t.string   "file_extension",             limit: 255
    t.integer  "learner_id",                 limit: 4
    t.string   "checksum",                   limit: 255
  end

  add_index "dataservice_blobs", ["bundle_content_id"], name: "index_dataservice_blobs_on_bundle_content_id", using: :btree
  add_index "dataservice_blobs", ["checksum"], name: "index_dataservice_blobs_on_checksum", using: :btree
  add_index "dataservice_blobs", ["learner_id"], name: "index_dataservice_blobs_on_learner_id", using: :btree
  add_index "dataservice_blobs", ["periodic_bundle_content_id"], name: "pbc_idx", using: :btree

  create_table "dataservice_bucket_contents", force: :cascade do |t|
    t.integer  "bucket_logger_id", limit: 4
    t.text     "body",             limit: 16777215
    t.boolean  "processed"
    t.boolean  "empty"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "dataservice_bucket_contents", ["bucket_logger_id"], name: "index_dataservice_bucket_contents_on_bucket_logger_id", using: :btree

  create_table "dataservice_bucket_log_items", force: :cascade do |t|
    t.text     "content",          limit: 16777215
    t.integer  "bucket_logger_id", limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "dataservice_bucket_log_items", ["bucket_logger_id"], name: "index_dataservice_bucket_log_items_on_bucket_logger_id", using: :btree

  create_table "dataservice_bucket_loggers", force: :cascade do |t|
    t.integer  "learner_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "name",       limit: 255
  end

  add_index "dataservice_bucket_loggers", ["learner_id"], name: "index_dataservice_bucket_loggers_on_learner_id", using: :btree
  add_index "dataservice_bucket_loggers", ["name"], name: "index_dataservice_bucket_loggers_on_name", using: :btree

  create_table "dataservice_bundle_contents", force: :cascade do |t|
    t.integer  "bundle_logger_id", limit: 4
    t.integer  "position",         limit: 4
    t.text     "body",             limit: 4294967295
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.text     "otml",             limit: 4294967295
    t.boolean  "processed"
    t.boolean  "valid_xml",                           default: false
    t.boolean  "empty",                               default: true
    t.string   "uuid",             limit: 36
    t.text     "original_body",    limit: 16777215
    t.float    "upload_time",      limit: 24
    t.integer  "collaboration_id", limit: 4
  end

  add_index "dataservice_bundle_contents", ["bundle_logger_id"], name: "index_dataservice_bundle_contents_on_bundle_logger_id", using: :btree
  add_index "dataservice_bundle_contents", ["collaboration_id"], name: "index_dataservice_bundle_contents_on_collaboration_id", using: :btree

  create_table "dataservice_bundle_loggers", force: :cascade do |t|
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "in_progress_bundle_id", limit: 4
  end

  add_index "dataservice_bundle_loggers", ["in_progress_bundle_id"], name: "index_dataservice_bundle_loggers_on_in_progress_bundle_id", using: :btree

  create_table "dataservice_console_contents", force: :cascade do |t|
    t.integer  "console_logger_id", limit: 4
    t.integer  "position",          limit: 4
    t.text     "body",              limit: 16777215
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "dataservice_console_loggers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dataservice_jnlp_sessions", force: :cascade do |t|
    t.string   "token",        limit: 255
    t.integer  "user_id",      limit: 4
    t.integer  "access_count", limit: 4,   default: 0
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "dataservice_jnlp_sessions", ["token"], name: "index_dataservice_jnlp_sessions_on_token", using: :btree

  create_table "dataservice_launch_process_events", force: :cascade do |t|
    t.string   "event_type",        limit: 255
    t.text     "event_details",     limit: 16777215
    t.integer  "bundle_content_id", limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "dataservice_launch_process_events", ["bundle_content_id"], name: "index_dataservice_launch_process_events_on_bundle_content_id", using: :btree

  create_table "dataservice_periodic_bundle_contents", force: :cascade do |t|
    t.integer  "periodic_bundle_logger_id", limit: 4
    t.text     "body",                      limit: 4294967295
    t.boolean  "processed"
    t.boolean  "valid_xml"
    t.boolean  "empty"
    t.string   "uuid",                      limit: 255
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.boolean  "parts_extracted",                              default: false
  end

  add_index "dataservice_periodic_bundle_contents", ["periodic_bundle_logger_id"], name: "bundle_logger_index", using: :btree

  create_table "dataservice_periodic_bundle_loggers", force: :cascade do |t|
    t.integer  "learner_id", limit: 4
    t.text     "imports",    limit: 16777215
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "dataservice_periodic_bundle_loggers", ["learner_id"], name: "learner_index", using: :btree

  create_table "dataservice_periodic_bundle_parts", force: :cascade do |t|
    t.integer  "periodic_bundle_logger_id", limit: 4
    t.boolean  "delta",                                        default: true
    t.string   "key",                       limit: 255
    t.text     "value",                     limit: 4294967295
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  add_index "dataservice_periodic_bundle_parts", ["key"], name: "parts_key_index", using: :btree
  add_index "dataservice_periodic_bundle_parts", ["periodic_bundle_logger_id"], name: "bundle_logger_index", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,          default: 0
    t.integer  "attempts",   limit: 4,          default: 0
    t.text     "handler",    limit: 4294967295
    t.text     "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "embeddable_iframes", force: :cascade do |t|
    t.integer  "user_id",                          limit: 4
    t.string   "uuid",                             limit: 36
    t.string   "name",                             limit: 255
    t.string   "description",                      limit: 255
    t.integer  "width",                            limit: 4
    t.integer  "height",                           limit: 4
    t.text     "url",                              limit: 65535
    t.string   "external_id",                      limit: 255
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.boolean  "display_in_iframe",                              default: false
    t.boolean  "is_required",                                    default: false
    t.boolean  "show_in_featured_question_report",               default: true
  end

  create_table "embeddable_image_questions", force: :cascade do |t|
    t.integer  "user_id",                          limit: 4
    t.string   "uuid",                             limit: 36
    t.string   "name",                             limit: 255
    t.text     "prompt",                           limit: 16777215
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.string   "external_id",                      limit: 255
    t.text     "drawing_prompt",                   limit: 16777215
    t.boolean  "is_required",                                       default: false, null: false
    t.boolean  "show_in_featured_question_report",                  default: true
  end

  create_table "embeddable_multiple_choice_choices", force: :cascade do |t|
    t.text     "choice",             limit: 16777215
    t.integer  "multiple_choice_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "is_correct"
    t.string   "external_id",        limit: 255
  end

  add_index "embeddable_multiple_choice_choices", ["multiple_choice_id"], name: "index_embeddable_multiple_choice_choices_on_multiple_choice_id", using: :btree

  create_table "embeddable_multiple_choices", force: :cascade do |t|
    t.integer  "user_id",                          limit: 4
    t.string   "uuid",                             limit: 36
    t.string   "name",                             limit: 255
    t.text     "description",                      limit: 16777215
    t.text     "prompt",                           limit: 16777215
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.boolean  "enable_rationale",                                  default: false
    t.text     "rationale_prompt",                 limit: 16777215
    t.boolean  "allow_multiple_selection",                          default: false
    t.string   "external_id",                      limit: 255
    t.boolean  "is_required",                                       default: false, null: false
    t.boolean  "show_in_featured_question_report",                  default: true
  end

  create_table "embeddable_open_responses", force: :cascade do |t|
    t.integer  "user_id",                          limit: 4
    t.string   "uuid",                             limit: 36
    t.string   "name",                             limit: 255
    t.text     "description",                      limit: 16777215
    t.text     "prompt",                           limit: 16777215
    t.string   "default_response",                 limit: 255
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.integer  "rows",                             limit: 4,        default: 5
    t.integer  "columns",                          limit: 4,        default: 32
    t.integer  "font_size",                        limit: 4,        default: 12
    t.string   "external_id",                      limit: 255
    t.boolean  "is_required",                                       default: false, null: false
    t.boolean  "show_in_featured_question_report",                  default: true
  end

  create_table "external_activities", force: :cascade do |t|
    t.integer  "user_id",                      limit: 4
    t.string   "uuid",                         limit: 255
    t.string   "name",                         limit: 255
    t.text     "archived_description",         limit: 16777215
    t.text     "url",                          limit: 16777215
    t.string   "publication_status",           limit: 255
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.integer  "offerings_count",              limit: 4,        default: 0
    t.string   "save_path",                    limit: 255
    t.boolean  "append_learner_id_to_url"
    t.boolean  "popup",                                         default: true
    t.boolean  "append_survey_monkey_uid"
    t.integer  "template_id",                  limit: 4
    t.string   "template_type",                limit: 255
    t.string   "launch_url",                   limit: 255
    t.boolean  "is_official",                                   default: false
    t.boolean  "student_report_enabled",                        default: true
    t.string   "teacher_guide_url",            limit: 255
    t.string   "thumbnail_url",                limit: 255
    t.boolean  "is_featured",                                   default: false
    t.boolean  "has_pretest",                                   default: false
    t.text     "short_description",            limit: 16777215
    t.boolean  "allow_collaboration",                           default: false
    t.string   "author_email",                 limit: 255
    t.boolean  "is_locked"
    t.boolean  "logging",                                       default: false
    t.boolean  "is_assessment_item",                            default: false
    t.text     "author_url",                   limit: 65535
    t.text     "print_url",                    limit: 65535
    t.boolean  "is_archived",                                   default: false
    t.datetime "archive_date"
    t.string   "credits",                      limit: 255
    t.string   "license_code",                 limit: 255
    t.boolean  "append_auth_token"
    t.boolean  "enable_sharing",                                default: true
    t.string   "material_type",                limit: 255,      default: "Activity"
    t.string   "rubric_url",                   limit: 255
    t.boolean  "saves_student_data",                            default: true
    t.text     "long_description_for_teacher", limit: 65535
    t.text     "long_description",             limit: 65535
    t.text     "keywords",                     limit: 65535
    t.integer  "tool_id",                      limit: 4
    t.boolean  "has_teacher_edition",                           default: false
    t.text     "teacher_resources_url",        limit: 65535
  end

  add_index "external_activities", ["is_featured", "publication_status"], name: "featured_public", using: :btree
  add_index "external_activities", ["publication_status"], name: "pub_status", using: :btree
  add_index "external_activities", ["save_path"], name: "index_external_activities_on_save_path", using: :btree
  add_index "external_activities", ["template_id", "template_type"], name: "index_external_activities_on_template_id_and_template_type", using: :btree
  add_index "external_activities", ["user_id"], name: "index_external_activities_on_user_id", using: :btree

  create_table "external_activity_reports", id: false, force: :cascade do |t|
    t.integer "external_activity_id", limit: 4
    t.integer "external_report_id",   limit: 4
  end

  add_index "external_activity_reports", ["external_activity_id", "external_report_id"], name: "activity_reports_activity_index", using: :btree
  add_index "external_activity_reports", ["external_report_id"], name: "activity_reports_index", using: :btree

  create_table "external_reports", force: :cascade do |t|
    t.string   "url",                            limit: 255
    t.string   "name",                           limit: 255
    t.string   "launch_text",                    limit: 255
    t.integer  "client_id",                      limit: 4
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.string   "report_type",                    limit: 255,   default: "offering"
    t.boolean  "allowed_for_students",                         default: false
    t.string   "default_report_for_source_type", limit: 255
    t.boolean  "individual_student_reportable",                default: false
    t.boolean  "individual_activity_reportable",               default: false
    t.text     "move_students_api_url",          limit: 65535
    t.string   "move_students_api_token",        limit: 255
    t.boolean  "use_query_jwt",                                default: false
  end

  add_index "external_reports", ["client_id"], name: "index_external_reports_on_client_id", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "favoritable_id",   limit: 4
    t.string   "favoritable_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "favorites", ["favoritable_id"], name: "index_favorites_on_favoritable_id", using: :btree
  add_index "favorites", ["favoritable_type"], name: "index_favorites_on_favoritable_type", using: :btree
  add_index "favorites", ["user_id", "favoritable_id", "favoritable_type"], name: "favorite_unique", unique: true, using: :btree

  create_table "firebase_apps", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "client_email", limit: 255
    t.text     "private_key",  limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "firebase_apps", ["name"], name: "index_firebase_apps_on_name", using: :btree

  create_table "geniverse_activities", force: :cascade do |t|
    t.text     "initial_alleles",            limit: 16777215
    t.string   "base_channel_name",          limit: 255
    t.integer  "max_users_in_room",          limit: 4
    t.boolean  "send_bred_dragons"
    t.string   "title",                      limit: 255
    t.string   "hidden_genes",               limit: 255
    t.text     "static_genes",               limit: 16777215
    t.boolean  "crossover_when_breeding",                     default: false
    t.string   "route",                      limit: 255
    t.string   "pageType",                   limit: 255
    t.text     "message",                    limit: 16777215
    t.text     "match_dragon_alleles",       limit: 16777215
    t.integer  "myCase_id",                  limit: 4
    t.integer  "myCaseOrder",                limit: 4
    t.boolean  "is_argumentation_challenge",                  default: false
    t.integer  "threshold_three_stars",      limit: 4
    t.integer  "threshold_two_stars",        limit: 4
    t.boolean  "show_color_labels"
    t.text     "congratulations",            limit: 16777215
    t.boolean  "show_tooltips",                               default: false
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  add_index "geniverse_activities", ["route"], name: "index_activities_on_route", using: :btree

  create_table "geniverse_articles", force: :cascade do |t|
    t.integer  "group",          limit: 4
    t.integer  "activity_id",    limit: 4
    t.text     "text",           limit: 16777215
    t.integer  "time",           limit: 4
    t.boolean  "submitted"
    t.text     "teacherComment", limit: 16777215
    t.boolean  "accepted"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "geniverse_cases", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "order",         limit: 4
    t.string   "introImageUrl", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "geniverse_dragons", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "sex",             limit: 4
    t.string   "alleles",         limit: 255
    t.string   "imageURL",        limit: 255
    t.integer  "mother_id",       limit: 4
    t.integer  "father_id",       limit: 4
    t.boolean  "bred"
    t.integer  "user_id",         limit: 4
    t.integer  "stableOrder",     limit: 4
    t.boolean  "isEgg",                       default: false
    t.boolean  "isInMarketplace",             default: true
    t.integer  "activity_id",     limit: 4
    t.integer  "breeder_id",      limit: 4
    t.string   "breedTime",       limit: 16
    t.boolean  "isMatchDragon",               default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "geniverse_dragons", ["activity_id"], name: "index_dragons_on_activity_id", using: :btree
  add_index "geniverse_dragons", ["breeder_id", "breedTime", "id"], name: "breed_record_index", using: :btree
  add_index "geniverse_dragons", ["father_id"], name: "father_index", using: :btree
  add_index "geniverse_dragons", ["id"], name: "index_dragons_on_id", using: :btree
  add_index "geniverse_dragons", ["mother_id"], name: "mother_index", using: :btree
  add_index "geniverse_dragons", ["user_id"], name: "index_dragons_on_user_id", using: :btree

  create_table "geniverse_help_messages", force: :cascade do |t|
    t.string   "page_name",  limit: 255
    t.text     "message",    limit: 16777215
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "geniverse_unlockables", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.text     "content",            limit: 16777215
    t.string   "trigger",            limit: 255
    t.boolean  "open_automatically",                  default: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "geniverse_users", force: :cascade do |t|
    t.string   "username",      limit: 255
    t.string   "password_hash", limit: 255
    t.integer  "group_id",      limit: 4
    t.integer  "member_id",     limit: 4
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.text     "note",          limit: 16777215
    t.string   "class_name",    limit: 255
    t.text     "metadata",      limit: 4294967295
    t.string   "avatar",        limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "geniverse_users", ["username", "password_hash"], name: "index_users_on_username_and_password_hash", length: {"username"=>125, "password_hash"=>125}, using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.string   "name",               limit: 255
    t.text     "attribution",        limit: 16777215
    t.string   "publication_status", limit: 255,      default: "published"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.string   "license_code",       limit: 255
    t.integer  "width",              limit: 4,        default: 0
    t.integer  "height",             limit: 4,        default: 0
  end

  create_table "import_duplicate_users", force: :cascade do |t|
    t.string  "login",        limit: 255
    t.string  "email",        limit: 255
    t.integer "duplicate_by", limit: 4
    t.text    "data",         limit: 16777215
    t.integer "user_id",      limit: 4
    t.integer "import_id",    limit: 4
  end

  create_table "import_school_district_mappings", force: :cascade do |t|
    t.integer "district_id",          limit: 4
    t.string  "import_district_uuid", limit: 255
  end

  create_table "import_user_school_mappings", force: :cascade do |t|
    t.integer "school_id",         limit: 4
    t.string  "import_school_url", limit: 255
  end

  create_table "imported_users", force: :cascade do |t|
    t.string  "user_url",         limit: 255
    t.boolean "is_verified"
    t.integer "user_id",          limit: 4
    t.string  "importing_domain", limit: 255
    t.integer "import_id",        limit: 4
  end

  create_table "imports", force: :cascade do |t|
    t.integer  "job_id",          limit: 4
    t.datetime "job_finished_at"
    t.integer  "import_type",     limit: 4
    t.integer  "progress",        limit: 4
    t.integer  "total_imports",   limit: 4
    t.integer  "user_id",         limit: 4
    t.text     "upload_data",     limit: 4294967295
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "import_data",     limit: 4294967295
  end

  create_table "interactives", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.text     "description",            limit: 16777215
    t.string   "url",                    limit: 255
    t.integer  "width",                  limit: 4
    t.integer  "height",                 limit: 4
    t.float    "scale",                  limit: 24
    t.string   "image_url",              limit: 255
    t.integer  "user_id",                limit: 4
    t.string   "credits",                limit: 255
    t.string   "publication_status",     limit: 255
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "full_window",                             default: false
    t.boolean  "no_snapshots",                            default: false
    t.boolean  "save_interactive_state",                  default: false
    t.string   "license_code",           limit: 255
    t.integer  "external_activity_id",   limit: 4
  end

  create_table "investigations", force: :cascade do |t|
    t.integer  "user_id",                   limit: 4
    t.string   "uuid",                      limit: 36
    t.string   "name",                      limit: 255
    t.text     "description",               limit: 16777215
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.boolean  "teacher_only",                               default: false
    t.string   "publication_status",        limit: 255
    t.integer  "offerings_count",           limit: 4,        default: 0
    t.boolean  "student_report_enabled",                     default: true
    t.boolean  "allow_activity_assignment",                  default: true
    t.boolean  "show_score",                                 default: false
    t.string   "teacher_guide_url",         limit: 255
    t.string   "thumbnail_url",             limit: 255
    t.boolean  "is_featured",                                default: false
    t.text     "abstract",                  limit: 16777215
    t.string   "author_email",              limit: 255
    t.boolean  "is_assessment_item",                         default: false
  end

  add_index "investigations", ["is_featured", "publication_status"], name: "featured_public", using: :btree
  add_index "investigations", ["publication_status"], name: "pub_status", using: :btree

  create_table "learner_processing_events", force: :cascade do |t|
    t.integer  "learner_id",      limit: 4
    t.datetime "portal_end"
    t.datetime "portal_start"
    t.datetime "lara_end"
    t.datetime "lara_start"
    t.integer  "elapsed_seconds", limit: 4
    t.string   "duration",        limit: 255
    t.string   "login",           limit: 255
    t.string   "teacher",         limit: 255
    t.string   "url",             limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "lara_duration",   limit: 4
    t.integer  "portal_duration", limit: 4
  end

  add_index "learner_processing_events", ["learner_id"], name: "index_learner_processing_events_on_learner_id", using: :btree
  add_index "learner_processing_events", ["url"], name: "index_learner_processing_events_on_url", using: :btree

  create_table "legacy_collaborations", force: :cascade do |t|
    t.integer  "bundle_content_id", limit: 4
    t.integer  "student_id",        limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "materials_collection_items", force: :cascade do |t|
    t.integer  "materials_collection_id", limit: 4
    t.string   "material_type",           limit: 255
    t.integer  "material_id",             limit: 4
    t.integer  "position",                limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "materials_collection_items", ["material_id", "material_type", "position"], name: "material_idx", using: :btree
  add_index "materials_collection_items", ["materials_collection_id", "position"], name: "materials_collection_idx", using: :btree

  create_table "materials_collections", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 16777215
    t.integer  "project_id",  limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "materials_collections", ["project_id"], name: "index_materials_collections_on_project_id", using: :btree

  create_table "otrunk_example_otrunk_imports", force: :cascade do |t|
    t.string   "uuid",         limit: 255
    t.string   "classname",    limit: 255
    t.string   "fq_classname", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "otrunk_example_otrunk_imports", ["fq_classname"], name: "index_otrunk_example_otrunk_imports_on_fq_classname", unique: true, using: :btree

  create_table "otrunk_example_otrunk_view_entries", force: :cascade do |t|
    t.string   "uuid",               limit: 255
    t.integer  "otrunk_import_id",   limit: 4
    t.string   "classname",          limit: 255
    t.string   "fq_classname",       limit: 255
    t.boolean  "standard_view"
    t.boolean  "standard_edit_view"
    t.boolean  "edit_view"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "otrunk_example_otrunk_view_entries", ["fq_classname"], name: "index_otrunk_example_otrunk_view_entries_on_fq_classname", unique: true, using: :btree

  create_table "page_elements", force: :cascade do |t|
    t.integer  "page_id",         limit: 4
    t.integer  "embeddable_id",   limit: 4
    t.string   "embeddable_type", limit: 255
    t.integer  "position",        limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_id",         limit: 4
  end

  add_index "page_elements", ["embeddable_id", "embeddable_type"], name: "index_page_elements_on_embeddable_id_and_embeddable_type", using: :btree
  add_index "page_elements", ["embeddable_id"], name: "index_page_elements_on_embeddable_id", using: :btree
  add_index "page_elements", ["page_id"], name: "index_page_elements_on_page_id", using: :btree
  add_index "page_elements", ["position"], name: "index_page_elements_on_position", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.integer  "section_id",         limit: 4
    t.string   "uuid",               limit: 36
    t.string   "name",               limit: 255
    t.text     "description",        limit: 16777215
    t.integer  "position",           limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "teacher_only",                        default: false
    t.string   "publication_status", limit: 255
    t.integer  "offerings_count",    limit: 4,        default: 0
    t.text     "url",                limit: 65535
  end

  add_index "pages", ["position"], name: "index_pages_on_position", using: :btree
  add_index "pages", ["section_id", "position"], name: "index_pages_on_section_id_and_position", using: :btree

  create_table "passwords", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.string   "reset_code",      limit: 255
    t.datetime "expiration_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "passwords", ["user_id"], name: "index_passwords_on_user_id", using: :btree

  create_table "portal_bookmark_visits", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "bookmark_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "portal_bookmarks", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "type",       limit: 255
    t.string   "url",        limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "position",   limit: 4
    t.integer  "clazz_id",   limit: 4
    t.boolean  "is_visible",             default: true, null: false
  end

  add_index "portal_bookmarks", ["clazz_id"], name: "index_bookmarks_on_clazz_id", using: :btree
  add_index "portal_bookmarks", ["id", "type"], name: "index_portal_bookmarks_on_id_and_type", using: :btree
  add_index "portal_bookmarks", ["user_id"], name: "index_portal_bookmarks_on_user_id", using: :btree

  create_table "portal_clazzes", force: :cascade do |t|
    t.string   "uuid",          limit: 36
    t.string   "name",          limit: 255
    t.text     "description",   limit: 16777215
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "class_word",    limit: 255
    t.string   "status",        limit: 255
    t.integer  "course_id",     limit: 4
    t.integer  "semester_id",   limit: 4
    t.integer  "teacher_id",    limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "section",       limit: 255
    t.boolean  "default_class",                  default: false
    t.boolean  "logging",                        default: false
    t.string   "class_hash",    limit: 48
  end

  add_index "portal_clazzes", ["class_word"], name: "index_portal_clazzes_on_class_word", unique: true, using: :btree

  create_table "portal_collaboration_memberships", force: :cascade do |t|
    t.integer  "collaboration_id", limit: 4
    t.integer  "student_id",       limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "portal_collaboration_memberships", ["collaboration_id", "student_id"], name: "index_portal_coll_mem_on_collaboration_id_and_student_id", using: :btree

  create_table "portal_collaborations", force: :cascade do |t|
    t.integer  "owner_id",    limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "offering_id", limit: 4
  end

  add_index "portal_collaborations", ["offering_id"], name: "index_portal_collaborations_on_offering_id", using: :btree
  add_index "portal_collaborations", ["owner_id"], name: "index_portal_collaborations_on_owner_id", using: :btree

  create_table "portal_countries", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "formal_name",  limit: 255
    t.string   "capital",      limit: 255
    t.string   "two_letter",   limit: 2
    t.string   "three_letter", limit: 3
    t.string   "tld",          limit: 255
    t.integer  "iso_id",       limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "portal_countries", ["iso_id"], name: "index_portal_countries_on_iso_id", using: :btree
  add_index "portal_countries", ["name"], name: "index_portal_countries_on_name", using: :btree
  add_index "portal_countries", ["two_letter"], name: "index_portal_countries_on_two_letter", using: :btree

  create_table "portal_courses", force: :cascade do |t|
    t.string   "uuid",          limit: 36
    t.string   "name",          limit: 255
    t.text     "description",   limit: 16777215
    t.integer  "school_id",     limit: 4
    t.string   "status",        limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "course_number", limit: 255
  end

  add_index "portal_courses", ["course_number"], name: "index_portal_courses_on_course_number", using: :btree
  add_index "portal_courses", ["name"], name: "index_portal_courses_on_name", using: :btree
  add_index "portal_courses", ["school_id"], name: "index_portal_courses_on_school_id", using: :btree

  create_table "portal_courses_grade_levels", id: false, force: :cascade do |t|
    t.integer "grade_level_id", limit: 4
    t.integer "course_id",      limit: 4
  end

  create_table "portal_districts", force: :cascade do |t|
    t.string   "uuid",             limit: 36
    t.string   "name",             limit: 255
    t.text     "description",      limit: 16777215
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "nces_district_id", limit: 4
    t.string   "state",            limit: 2
    t.string   "leaid",            limit: 7
    t.string   "zipcode",          limit: 5
  end

  add_index "portal_districts", ["nces_district_id"], name: "index_portal_districts_on_nces_district_id", using: :btree
  add_index "portal_districts", ["state"], name: "index_portal_districts_on_state", using: :btree

  create_table "portal_grade_levels", force: :cascade do |t|
    t.string   "uuid",                  limit: 36
    t.string   "name",                  limit: 255
    t.text     "description",           limit: 16777215
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "has_grade_levels_id",   limit: 4
    t.string   "has_grade_levels_type", limit: 255
    t.integer  "grade_id",              limit: 4
  end

  create_table "portal_grade_levels_teachers", id: false, force: :cascade do |t|
    t.integer "grade_level_id", limit: 4
    t.integer "teacher_id",     limit: 4
  end

  create_table "portal_grades", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.integer  "position",    limit: 4
    t.string   "uuid",        limit: 255
    t.boolean  "active",                  default: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "portal_learner_activity_feedbacks", force: :cascade do |t|
    t.text     "text_feedback",        limit: 65535
    t.integer  "score",                limit: 4,     default: 0
    t.boolean  "has_been_reviewed",                  default: false
    t.integer  "portal_learner_id",    limit: 4
    t.integer  "activity_feedback_id", limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.text     "rubric_feedback",      limit: 65535
  end

  add_index "portal_learner_activity_feedbacks", ["activity_feedback_id"], name: "index_portal_learner_activity_feedbacks_on_activity_feedback_id", using: :btree
  add_index "portal_learner_activity_feedbacks", ["portal_learner_id"], name: "index_portal_learner_activity_feedbacks_on_portal_learner_id", using: :btree

  create_table "portal_learners", force: :cascade do |t|
    t.string   "uuid",              limit: 36
    t.integer  "student_id",        limit: 4
    t.integer  "offering_id",       limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "bundle_logger_id",  limit: 4
    t.integer  "console_logger_id", limit: 4
    t.string   "secure_key",        limit: 255
  end

  add_index "portal_learners", ["bundle_logger_id"], name: "index_portal_learners_on_bundle_logger_id", using: :btree
  add_index "portal_learners", ["console_logger_id"], name: "index_portal_learners_on_console_logger_id", using: :btree
  add_index "portal_learners", ["offering_id"], name: "index_portal_learners_on_offering_id", using: :btree
  add_index "portal_learners", ["secure_key"], name: "index_portal_learners_on_sec_key", unique: true, using: :btree
  add_index "portal_learners", ["student_id"], name: "index_portal_learners_on_student_id", using: :btree

  create_table "portal_nces06_districts", force: :cascade do |t|
    t.string  "LEAID",  limit: 7
    t.string  "FIPST",  limit: 2
    t.string  "STID",   limit: 14
    t.string  "NAME",   limit: 60
    t.string  "PHONE",  limit: 10
    t.string  "MSTREE", limit: 30
    t.string  "MCITY",  limit: 30
    t.string  "MSTATE", limit: 2
    t.string  "MZIP",   limit: 5
    t.string  "MZIP4",  limit: 4
    t.string  "LSTREE", limit: 30
    t.string  "LCITY",  limit: 30
    t.string  "LSTATE", limit: 2
    t.string  "LZIP",   limit: 5
    t.string  "LZIP4",  limit: 4
    t.string  "KIND",   limit: 1
    t.string  "UNION",  limit: 3
    t.string  "CONUM",  limit: 5
    t.string  "CONAME", limit: 30
    t.string  "CSA",    limit: 3
    t.string  "CBSA",   limit: 5
    t.string  "METMIC", limit: 1
    t.string  "MSC",    limit: 1
    t.string  "ULOCAL", limit: 2
    t.string  "CDCODE", limit: 4
    t.float   "LATCOD", limit: 24
    t.float   "LONCOD", limit: 24
    t.string  "BOUND",  limit: 1
    t.string  "GSLO",   limit: 2
    t.string  "GSHI",   limit: 2
    t.string  "AGCHRT", limit: 1
    t.integer "SCH",    limit: 4
    t.float   "TEACH",  limit: 24
    t.integer "UG",     limit: 4
    t.integer "PK12",   limit: 4
    t.integer "MEMBER", limit: 4
    t.integer "MIGRNT", limit: 4
    t.integer "SPECED", limit: 4
    t.integer "ELL",    limit: 4
    t.float   "PKTCH",  limit: 24
    t.float   "KGTCH",  limit: 24
    t.float   "ELMTCH", limit: 24
    t.float   "SECTCH", limit: 24
    t.float   "UGTCH",  limit: 24
    t.float   "TOTTCH", limit: 24
    t.float   "AIDES",  limit: 24
    t.float   "CORSUP", limit: 24
    t.float   "ELMGUI", limit: 24
    t.float   "SECGUI", limit: 24
    t.float   "TOTGUI", limit: 24
    t.float   "LIBSPE", limit: 24
    t.float   "LIBSUP", limit: 24
    t.float   "LEAADM", limit: 24
    t.float   "LEASUP", limit: 24
    t.float   "SCHADM", limit: 24
    t.float   "SCHSUP", limit: 24
    t.float   "STUSUP", limit: 24
    t.float   "OTHSUP", limit: 24
    t.string  "IGSLO",  limit: 1
    t.string  "IGSHI",  limit: 1
    t.string  "ISCH",   limit: 1
    t.string  "ITEACH", limit: 1
    t.string  "IUG",    limit: 1
    t.string  "IPK12",  limit: 1
    t.string  "IMEMB",  limit: 1
    t.string  "IMIGRN", limit: 1
    t.string  "ISPEC",  limit: 1
    t.string  "IELL",   limit: 1
    t.string  "IPKTCH", limit: 1
    t.string  "IKGTCH", limit: 1
    t.string  "IELTCH", limit: 1
    t.string  "ISETCH", limit: 1
    t.string  "IUGTCH", limit: 1
    t.string  "ITOTCH", limit: 1
    t.string  "IAIDES", limit: 1
    t.string  "ICOSUP", limit: 1
    t.string  "IELGUI", limit: 1
    t.string  "ISEGUI", limit: 1
    t.string  "ITOGUI", limit: 1
    t.string  "ILISPE", limit: 1
    t.string  "ILISUP", limit: 1
    t.string  "ILEADM", limit: 1
    t.string  "ILESUP", limit: 1
    t.string  "ISCADM", limit: 1
    t.string  "ISCSUP", limit: 1
    t.string  "ISTSUP", limit: 1
    t.string  "IOTSUP", limit: 1
  end

  add_index "portal_nces06_districts", ["LEAID"], name: "index_portal_nces06_districts_on_LEAID", using: :btree
  add_index "portal_nces06_districts", ["NAME"], name: "index_portal_nces06_districts_on_NAME", using: :btree
  add_index "portal_nces06_districts", ["STID"], name: "index_portal_nces06_districts_on_STID", using: :btree

  create_table "portal_nces06_schools", force: :cascade do |t|
    t.integer "nces_district_id", limit: 4
    t.string  "NCESSCH",          limit: 12
    t.string  "FIPST",            limit: 2
    t.string  "LEAID",            limit: 7
    t.string  "SCHNO",            limit: 5
    t.string  "STID",             limit: 14
    t.string  "SEASCH",           limit: 20
    t.string  "LEANM",            limit: 60
    t.string  "SCHNAM",           limit: 50
    t.string  "PHONE",            limit: 10
    t.string  "MSTREE",           limit: 30
    t.string  "MCITY",            limit: 30
    t.string  "MSTATE",           limit: 2
    t.string  "MZIP",             limit: 5
    t.string  "MZIP4",            limit: 4
    t.string  "LSTREE",           limit: 30
    t.string  "LCITY",            limit: 30
    t.string  "LSTATE",           limit: 2
    t.string  "LZIP",             limit: 5
    t.string  "LZIP4",            limit: 4
    t.string  "KIND",             limit: 1
    t.string  "STATUS",           limit: 1
    t.string  "ULOCAL",           limit: 2
    t.float   "LATCOD",           limit: 24
    t.float   "LONCOD",           limit: 24
    t.string  "CDCODE",           limit: 4
    t.string  "CONUM",            limit: 5
    t.string  "CONAME",           limit: 30
    t.float   "FTE",              limit: 24
    t.string  "GSLO",             limit: 2
    t.string  "GSHI",             limit: 2
    t.string  "LEVEL",            limit: 1
    t.string  "TITLEI",           limit: 1
    t.string  "STITLI",           limit: 1
    t.string  "MAGNET",           limit: 1
    t.string  "CHARTR",           limit: 1
    t.string  "SHARED",           limit: 1
    t.integer "FRELCH",           limit: 4
    t.integer "REDLCH",           limit: 4
    t.integer "TOTFRL",           limit: 4
    t.integer "MIGRNT",           limit: 4
    t.integer "PK",               limit: 4
    t.integer "AMPKM",            limit: 4
    t.integer "AMPKF",            limit: 4
    t.integer "AMPKU",            limit: 4
    t.integer "ASPKM",            limit: 4
    t.integer "ASPKF",            limit: 4
    t.integer "ASPKU",            limit: 4
    t.integer "HIPKM",            limit: 4
    t.integer "HIPKF",            limit: 4
    t.integer "HIPKU",            limit: 4
    t.integer "BLPKM",            limit: 4
    t.integer "BLPKF",            limit: 4
    t.integer "BLPKU",            limit: 4
    t.integer "WHPKM",            limit: 4
    t.integer "WHPKF",            limit: 4
    t.integer "WHPKU",            limit: 4
    t.integer "KG",               limit: 4
    t.integer "AMKGM",            limit: 4
    t.integer "AMKGF",            limit: 4
    t.integer "AMKGU",            limit: 4
    t.integer "ASKGM",            limit: 4
    t.integer "ASKGF",            limit: 4
    t.integer "ASKGU",            limit: 4
    t.integer "HIKGM",            limit: 4
    t.integer "HIKGF",            limit: 4
    t.integer "HIKGU",            limit: 4
    t.integer "BLKGM",            limit: 4
    t.integer "BLKGF",            limit: 4
    t.integer "BLKGU",            limit: 4
    t.integer "WHKGM",            limit: 4
    t.integer "WHKGF",            limit: 4
    t.integer "WHKGU",            limit: 4
    t.integer "G01",              limit: 4
    t.integer "AM01M",            limit: 4
    t.integer "AM01F",            limit: 4
    t.integer "AM01U",            limit: 4
    t.integer "AS01M",            limit: 4
    t.integer "AS01F",            limit: 4
    t.integer "AS01U",            limit: 4
    t.integer "HI01M",            limit: 4
    t.integer "HI01F",            limit: 4
    t.integer "HI01U",            limit: 4
    t.integer "BL01M",            limit: 4
    t.integer "BL01F",            limit: 4
    t.integer "BL01U",            limit: 4
    t.integer "WH01M",            limit: 4
    t.integer "WH01F",            limit: 4
    t.integer "WH01U",            limit: 4
    t.integer "G02",              limit: 4
    t.integer "AM02M",            limit: 4
    t.integer "AM02F",            limit: 4
    t.integer "AM02U",            limit: 4
    t.integer "AS02M",            limit: 4
    t.integer "AS02F",            limit: 4
    t.integer "AS02U",            limit: 4
    t.integer "HI02M",            limit: 4
    t.integer "HI02F",            limit: 4
    t.integer "HI02U",            limit: 4
    t.integer "BL02M",            limit: 4
    t.integer "BL02F",            limit: 4
    t.integer "BL02U",            limit: 4
    t.integer "WH02M",            limit: 4
    t.integer "WH02F",            limit: 4
    t.integer "WH02U",            limit: 4
    t.integer "G03",              limit: 4
    t.integer "AM03M",            limit: 4
    t.integer "AM03F",            limit: 4
    t.integer "AM03U",            limit: 4
    t.integer "AS03M",            limit: 4
    t.integer "AS03F",            limit: 4
    t.integer "AS03U",            limit: 4
    t.integer "HI03M",            limit: 4
    t.integer "HI03F",            limit: 4
    t.integer "HI03U",            limit: 4
    t.integer "BL03M",            limit: 4
    t.integer "BL03F",            limit: 4
    t.integer "BL03U",            limit: 4
    t.integer "WH03M",            limit: 4
    t.integer "WH03F",            limit: 4
    t.integer "WH03U",            limit: 4
    t.integer "G04",              limit: 4
    t.integer "AM04M",            limit: 4
    t.integer "AM04F",            limit: 4
    t.integer "AM04U",            limit: 4
    t.integer "AS04M",            limit: 4
    t.integer "AS04F",            limit: 4
    t.integer "AS04U",            limit: 4
    t.integer "HI04M",            limit: 4
    t.integer "HI04F",            limit: 4
    t.integer "HI04U",            limit: 4
    t.integer "BL04M",            limit: 4
    t.integer "BL04F",            limit: 4
    t.integer "BL04U",            limit: 4
    t.integer "WH04M",            limit: 4
    t.integer "WH04F",            limit: 4
    t.integer "WH04U",            limit: 4
    t.integer "G05",              limit: 4
    t.integer "AM05M",            limit: 4
    t.integer "AM05F",            limit: 4
    t.integer "AM05U",            limit: 4
    t.integer "AS05M",            limit: 4
    t.integer "AS05F",            limit: 4
    t.integer "AS05U",            limit: 4
    t.integer "HI05M",            limit: 4
    t.integer "HI05F",            limit: 4
    t.integer "HI05U",            limit: 4
    t.integer "BL05M",            limit: 4
    t.integer "BL05F",            limit: 4
    t.integer "BL05U",            limit: 4
    t.integer "WH05M",            limit: 4
    t.integer "WH05F",            limit: 4
    t.integer "WH05U",            limit: 4
    t.integer "G06",              limit: 4
    t.integer "AM06M",            limit: 4
    t.integer "AM06F",            limit: 4
    t.integer "AM06U",            limit: 4
    t.integer "AS06M",            limit: 4
    t.integer "AS06F",            limit: 4
    t.integer "AS06U",            limit: 4
    t.integer "HI06M",            limit: 4
    t.integer "HI06F",            limit: 4
    t.integer "HI06U",            limit: 4
    t.integer "BL06M",            limit: 4
    t.integer "BL06F",            limit: 4
    t.integer "BL06U",            limit: 4
    t.integer "WH06M",            limit: 4
    t.integer "WH06F",            limit: 4
    t.integer "WH06U",            limit: 4
    t.integer "G07",              limit: 4
    t.integer "AM07M",            limit: 4
    t.integer "AM07F",            limit: 4
    t.integer "AM07U",            limit: 4
    t.integer "AS07M",            limit: 4
    t.integer "AS07F",            limit: 4
    t.integer "AS07U",            limit: 4
    t.integer "HI07M",            limit: 4
    t.integer "HI07F",            limit: 4
    t.integer "HI07U",            limit: 4
    t.integer "BL07M",            limit: 4
    t.integer "BL07F",            limit: 4
    t.integer "BL07U",            limit: 4
    t.integer "WH07M",            limit: 4
    t.integer "WH07F",            limit: 4
    t.integer "WH07U",            limit: 4
    t.integer "G08",              limit: 4
    t.integer "AM08M",            limit: 4
    t.integer "AM08F",            limit: 4
    t.integer "AM08U",            limit: 4
    t.integer "AS08M",            limit: 4
    t.integer "AS08F",            limit: 4
    t.integer "AS08U",            limit: 4
    t.integer "HI08M",            limit: 4
    t.integer "HI08F",            limit: 4
    t.integer "HI08U",            limit: 4
    t.integer "BL08M",            limit: 4
    t.integer "BL08F",            limit: 4
    t.integer "BL08U",            limit: 4
    t.integer "WH08M",            limit: 4
    t.integer "WH08F",            limit: 4
    t.integer "WH08U",            limit: 4
    t.integer "G09",              limit: 4
    t.integer "AM09M",            limit: 4
    t.integer "AM09F",            limit: 4
    t.integer "AM09U",            limit: 4
    t.integer "AS09M",            limit: 4
    t.integer "AS09F",            limit: 4
    t.integer "AS09U",            limit: 4
    t.integer "HI09M",            limit: 4
    t.integer "HI09F",            limit: 4
    t.integer "HI09U",            limit: 4
    t.integer "BL09M",            limit: 4
    t.integer "BL09F",            limit: 4
    t.integer "BL09U",            limit: 4
    t.integer "WH09M",            limit: 4
    t.integer "WH09F",            limit: 4
    t.integer "WH09U",            limit: 4
    t.integer "G10",              limit: 4
    t.integer "AM10M",            limit: 4
    t.integer "AM10F",            limit: 4
    t.integer "AM10U",            limit: 4
    t.integer "AS10M",            limit: 4
    t.integer "AS10F",            limit: 4
    t.integer "AS10U",            limit: 4
    t.integer "HI10M",            limit: 4
    t.integer "HI10F",            limit: 4
    t.integer "HI10U",            limit: 4
    t.integer "BL10M",            limit: 4
    t.integer "BL10F",            limit: 4
    t.integer "BL10U",            limit: 4
    t.integer "WH10M",            limit: 4
    t.integer "WH10F",            limit: 4
    t.integer "WH10U",            limit: 4
    t.integer "G11",              limit: 4
    t.integer "AM11M",            limit: 4
    t.integer "AM11F",            limit: 4
    t.integer "AM11U",            limit: 4
    t.integer "AS11M",            limit: 4
    t.integer "AS11F",            limit: 4
    t.integer "AS11U",            limit: 4
    t.integer "HI11M",            limit: 4
    t.integer "HI11F",            limit: 4
    t.integer "HI11U",            limit: 4
    t.integer "BL11M",            limit: 4
    t.integer "BL11F",            limit: 4
    t.integer "BL11U",            limit: 4
    t.integer "WH11M",            limit: 4
    t.integer "WH11F",            limit: 4
    t.integer "WH11U",            limit: 4
    t.integer "G12",              limit: 4
    t.integer "AM12M",            limit: 4
    t.integer "AM12F",            limit: 4
    t.integer "AM12U",            limit: 4
    t.integer "AS12M",            limit: 4
    t.integer "AS12F",            limit: 4
    t.integer "AS12U",            limit: 4
    t.integer "HI12M",            limit: 4
    t.integer "HI12F",            limit: 4
    t.integer "HI12U",            limit: 4
    t.integer "BL12M",            limit: 4
    t.integer "BL12F",            limit: 4
    t.integer "BL12U",            limit: 4
    t.integer "WH12M",            limit: 4
    t.integer "WH12F",            limit: 4
    t.integer "WH12U",            limit: 4
    t.integer "UG",               limit: 4
    t.integer "AMUGM",            limit: 4
    t.integer "AMUGF",            limit: 4
    t.integer "AMUGU",            limit: 4
    t.integer "ASUGM",            limit: 4
    t.integer "ASUGF",            limit: 4
    t.integer "ASUGU",            limit: 4
    t.integer "HIUGM",            limit: 4
    t.integer "HIUGF",            limit: 4
    t.integer "HIUGU",            limit: 4
    t.integer "BLUGM",            limit: 4
    t.integer "BLUGF",            limit: 4
    t.integer "BLUGU",            limit: 4
    t.integer "WHUGM",            limit: 4
    t.integer "WHUGF",            limit: 4
    t.integer "WHUGU",            limit: 4
    t.integer "MEMBER",           limit: 4
    t.integer "AM",               limit: 4
    t.integer "AMALM",            limit: 4
    t.integer "AMALF",            limit: 4
    t.integer "AMALU",            limit: 4
    t.integer "ASIAN",            limit: 4
    t.integer "ASALM",            limit: 4
    t.integer "ASALF",            limit: 4
    t.integer "ASALU",            limit: 4
    t.integer "HISP",             limit: 4
    t.integer "HIALM",            limit: 4
    t.integer "HIALF",            limit: 4
    t.integer "HIALU",            limit: 4
    t.integer "BLACK",            limit: 4
    t.integer "BLALM",            limit: 4
    t.integer "BLALF",            limit: 4
    t.integer "BLALU",            limit: 4
    t.integer "WHITE",            limit: 4
    t.integer "WHALM",            limit: 4
    t.integer "WHALF",            limit: 4
    t.integer "WHALU",            limit: 4
    t.integer "TOTETH",           limit: 4
    t.float   "PUPTCH",           limit: 24
    t.integer "TOTGRD",           limit: 4
    t.string  "IFTE",             limit: 1
    t.string  "IGSLO",            limit: 1
    t.string  "IGSHI",            limit: 1
    t.string  "ITITLI",           limit: 1
    t.string  "ISTITL",           limit: 1
    t.string  "IMAGNE",           limit: 1
    t.string  "ICHART",           limit: 1
    t.string  "ISHARE",           limit: 1
    t.string  "IFRELC",           limit: 1
    t.string  "IREDLC",           limit: 1
    t.string  "ITOTFR",           limit: 1
    t.string  "IMIGRN",           limit: 1
    t.string  "IPK",              limit: 1
    t.string  "IAMPKM",           limit: 1
    t.string  "IAMPKF",           limit: 1
    t.string  "IAMPKU",           limit: 1
    t.string  "IASPKM",           limit: 1
    t.string  "IASPKF",           limit: 1
    t.string  "IASPKU",           limit: 1
    t.string  "IHIPKM",           limit: 1
    t.string  "IHIPKF",           limit: 1
    t.string  "IHIPKU",           limit: 1
    t.string  "IBLPKM",           limit: 1
    t.string  "IBLPKF",           limit: 1
    t.string  "IBLPKU",           limit: 1
    t.string  "IWHPKM",           limit: 1
    t.string  "IWHPKF",           limit: 1
    t.string  "IWHPKU",           limit: 1
    t.string  "IKG",              limit: 1
    t.string  "IAMKGM",           limit: 1
    t.string  "IAMKGF",           limit: 1
    t.string  "IAMKGU",           limit: 1
    t.string  "IASKGM",           limit: 1
    t.string  "IASKGF",           limit: 1
    t.string  "IASKGU",           limit: 1
    t.string  "IHIKGM",           limit: 1
    t.string  "IHIKGF",           limit: 1
    t.string  "IHIKGU",           limit: 1
    t.string  "IBLKGM",           limit: 1
    t.string  "IBLKGF",           limit: 1
    t.string  "IBLKGU",           limit: 1
    t.string  "IWHKGM",           limit: 1
    t.string  "IWHKGF",           limit: 1
    t.string  "IWHKGU",           limit: 1
    t.string  "IG01",             limit: 1
    t.string  "IAM01M",           limit: 1
    t.string  "IAM01F",           limit: 1
    t.string  "IAM01U",           limit: 1
    t.string  "IAS01M",           limit: 1
    t.string  "IAS01F",           limit: 1
    t.string  "IAS01U",           limit: 1
    t.string  "IHI01M",           limit: 1
    t.string  "IHI01F",           limit: 1
    t.string  "IHI01U",           limit: 1
    t.string  "IBL01M",           limit: 1
    t.string  "IBL01F",           limit: 1
    t.string  "IBL01U",           limit: 1
    t.string  "IWH01M",           limit: 1
    t.string  "IWH01F",           limit: 1
    t.string  "IWH01U",           limit: 1
    t.string  "IG02",             limit: 1
    t.string  "IAM02M",           limit: 1
    t.string  "IAM02F",           limit: 1
    t.string  "IAM02U",           limit: 1
    t.string  "IAS02M",           limit: 1
    t.string  "IAS02F",           limit: 1
    t.string  "IAS02U",           limit: 1
    t.string  "IHI02M",           limit: 1
    t.string  "IHI02F",           limit: 1
    t.string  "IHI02U",           limit: 1
    t.string  "IBL02M",           limit: 1
    t.string  "IBL02F",           limit: 1
    t.string  "IBL02U",           limit: 1
    t.string  "IWH02M",           limit: 1
    t.string  "IWH02F",           limit: 1
    t.string  "IWH02U",           limit: 1
    t.string  "IG03",             limit: 1
    t.string  "IAM03M",           limit: 1
    t.string  "IAM03F",           limit: 1
    t.string  "IAM03U",           limit: 1
    t.string  "IAS03M",           limit: 1
    t.string  "IAS03F",           limit: 1
    t.string  "IAS03U",           limit: 1
    t.string  "IHI03M",           limit: 1
    t.string  "IHI03F",           limit: 1
    t.string  "IHI03U",           limit: 1
    t.string  "IBL03M",           limit: 1
    t.string  "IBL03F",           limit: 1
    t.string  "IBL03U",           limit: 1
    t.string  "IWH03M",           limit: 1
    t.string  "IWH03F",           limit: 1
    t.string  "IWH03U",           limit: 1
    t.string  "IG04",             limit: 1
    t.string  "IAM04M",           limit: 1
    t.string  "IAM04F",           limit: 1
    t.string  "IAM04U",           limit: 1
    t.string  "IAS04M",           limit: 1
    t.string  "IAS04F",           limit: 1
    t.string  "IAS04U",           limit: 1
    t.string  "IHI04M",           limit: 1
    t.string  "IHI04F",           limit: 1
    t.string  "IHI04U",           limit: 1
    t.string  "IBL04M",           limit: 1
    t.string  "IBL04F",           limit: 1
    t.string  "IBL04U",           limit: 1
    t.string  "IWH04M",           limit: 1
    t.string  "IWH04F",           limit: 1
    t.string  "IWH04U",           limit: 1
    t.string  "IG05",             limit: 1
    t.string  "IAM05M",           limit: 1
    t.string  "IAM05F",           limit: 1
    t.string  "IAM05U",           limit: 1
    t.string  "IAS05M",           limit: 1
    t.string  "IAS05F",           limit: 1
    t.string  "IAS05U",           limit: 1
    t.string  "IHI05M",           limit: 1
    t.string  "IHI05F",           limit: 1
    t.string  "IHI05U",           limit: 1
    t.string  "IBL05M",           limit: 1
    t.string  "IBL05F",           limit: 1
    t.string  "IBL05U",           limit: 1
    t.string  "IWH05M",           limit: 1
    t.string  "IWH05F",           limit: 1
    t.string  "IWH05U",           limit: 1
    t.string  "IG06",             limit: 1
    t.string  "IAM06M",           limit: 1
    t.string  "IAM06F",           limit: 1
    t.string  "IAM06U",           limit: 1
    t.string  "IAS06M",           limit: 1
    t.string  "IAS06F",           limit: 1
    t.string  "IAS06U",           limit: 1
    t.string  "IHI06M",           limit: 1
    t.string  "IHI06F",           limit: 1
    t.string  "IHI06U",           limit: 1
    t.string  "IBL06M",           limit: 1
    t.string  "IBL06F",           limit: 1
    t.string  "IBL06U",           limit: 1
    t.string  "IWH06M",           limit: 1
    t.string  "IWH06F",           limit: 1
    t.string  "IWH06U",           limit: 1
    t.string  "IG07",             limit: 1
    t.string  "IAM07M",           limit: 1
    t.string  "IAM07F",           limit: 1
    t.string  "IAM07U",           limit: 1
    t.string  "IAS07M",           limit: 1
    t.string  "IAS07F",           limit: 1
    t.string  "IAS07U",           limit: 1
    t.string  "IHI07M",           limit: 1
    t.string  "IHI07F",           limit: 1
    t.string  "IHI07U",           limit: 1
    t.string  "IBL07M",           limit: 1
    t.string  "IBL07F",           limit: 1
    t.string  "IBL07U",           limit: 1
    t.string  "IWH07M",           limit: 1
    t.string  "IWH07F",           limit: 1
    t.string  "IWH07U",           limit: 1
    t.string  "IG08",             limit: 1
    t.string  "IAM08M",           limit: 1
    t.string  "IAM08F",           limit: 1
    t.string  "IAM08U",           limit: 1
    t.string  "IAS08M",           limit: 1
    t.string  "IAS08F",           limit: 1
    t.string  "IAS08U",           limit: 1
    t.string  "IHI08M",           limit: 1
    t.string  "IHI08F",           limit: 1
    t.string  "IHI08U",           limit: 1
    t.string  "IBL08M",           limit: 1
    t.string  "IBL08F",           limit: 1
    t.string  "IBL08U",           limit: 1
    t.string  "IWH08M",           limit: 1
    t.string  "IWH08F",           limit: 1
    t.string  "IWH08U",           limit: 1
    t.string  "IG09",             limit: 1
    t.string  "IAM09M",           limit: 1
    t.string  "IAM09F",           limit: 1
    t.string  "IAM09U",           limit: 1
    t.string  "IAS09M",           limit: 1
    t.string  "IAS09F",           limit: 1
    t.string  "IAS09U",           limit: 1
    t.string  "IHI09M",           limit: 1
    t.string  "IHI09F",           limit: 1
    t.string  "IHI09U",           limit: 1
    t.string  "IBL09M",           limit: 1
    t.string  "IBL09F",           limit: 1
    t.string  "IBL09U",           limit: 1
    t.string  "IWH09M",           limit: 1
    t.string  "IWH09F",           limit: 1
    t.string  "IWH09U",           limit: 1
    t.string  "IG10",             limit: 1
    t.string  "IAM10M",           limit: 1
    t.string  "IAM10F",           limit: 1
    t.string  "IAM10U",           limit: 1
    t.string  "IAS10M",           limit: 1
    t.string  "IAS10F",           limit: 1
    t.string  "IAS10U",           limit: 1
    t.string  "IHI10M",           limit: 1
    t.string  "IHI10F",           limit: 1
    t.string  "IHI10U",           limit: 1
    t.string  "IBL10M",           limit: 1
    t.string  "IBL10F",           limit: 1
    t.string  "IBL10U",           limit: 1
    t.string  "IWH10M",           limit: 1
    t.string  "IWH10F",           limit: 1
    t.string  "IWH10U",           limit: 1
    t.string  "IG11",             limit: 1
    t.string  "IAM11M",           limit: 1
    t.string  "IAM11F",           limit: 1
    t.string  "IAM11U",           limit: 1
    t.string  "IAS11M",           limit: 1
    t.string  "IAS11F",           limit: 1
    t.string  "IAS11U",           limit: 1
    t.string  "IHI11M",           limit: 1
    t.string  "IHI11F",           limit: 1
    t.string  "IHI11U",           limit: 1
    t.string  "IBL11M",           limit: 1
    t.string  "IBL11F",           limit: 1
    t.string  "IBL11U",           limit: 1
    t.string  "IWH11M",           limit: 1
    t.string  "IWH11F",           limit: 1
    t.string  "IWH11U",           limit: 1
    t.string  "IG12",             limit: 1
    t.string  "IAM12M",           limit: 1
    t.string  "IAM12F",           limit: 1
    t.string  "IAM12U",           limit: 1
    t.string  "IAS12M",           limit: 1
    t.string  "IAS12F",           limit: 1
    t.string  "IAS12U",           limit: 1
    t.string  "IHI12M",           limit: 1
    t.string  "IHI12F",           limit: 1
    t.string  "IHI12U",           limit: 1
    t.string  "IBL12M",           limit: 1
    t.string  "IBL12F",           limit: 1
    t.string  "IBL12U",           limit: 1
    t.string  "IWH12M",           limit: 1
    t.string  "IWH12F",           limit: 1
    t.string  "IWH12U",           limit: 1
    t.string  "IUG",              limit: 1
    t.string  "IAMUGM",           limit: 1
    t.string  "IAMUGF",           limit: 1
    t.string  "IAMUGU",           limit: 1
    t.string  "IASUGM",           limit: 1
    t.string  "IASUGF",           limit: 1
    t.string  "IASUGU",           limit: 1
    t.string  "IHIUGM",           limit: 1
    t.string  "IHIUGF",           limit: 1
    t.string  "IHIUGU",           limit: 1
    t.string  "IBLUGM",           limit: 1
    t.string  "IBLUGF",           limit: 1
    t.string  "IBLUGU",           limit: 1
    t.string  "IWHUGM",           limit: 1
    t.string  "IWHUGF",           limit: 1
    t.string  "IWHUGU",           limit: 1
    t.string  "IMEMB",            limit: 1
    t.string  "IAM",              limit: 1
    t.string  "IAMALM",           limit: 1
    t.string  "IAMALF",           limit: 1
    t.string  "IAMALU",           limit: 1
    t.string  "IASIAN",           limit: 1
    t.string  "IASALM",           limit: 1
    t.string  "IASALF",           limit: 1
    t.string  "IASALU",           limit: 1
    t.string  "IHISP",            limit: 1
    t.string  "IHIALM",           limit: 1
    t.string  "IHIALF",           limit: 1
    t.string  "IHIALU",           limit: 1
    t.string  "IBLACK",           limit: 1
    t.string  "IBLALM",           limit: 1
    t.string  "IBLALF",           limit: 1
    t.string  "IBLALU",           limit: 1
    t.string  "IWHITE",           limit: 1
    t.string  "IWHALM",           limit: 1
    t.string  "IWHALF",           limit: 1
    t.string  "IWHALU",           limit: 1
    t.string  "IETH",             limit: 1
    t.string  "IPUTCH",           limit: 1
    t.string  "ITOTGR",           limit: 1
  end

  add_index "portal_nces06_schools", ["NCESSCH"], name: "index_portal_nces06_schools_on_NCESSCH", using: :btree
  add_index "portal_nces06_schools", ["SCHNAM"], name: "index_portal_nces06_schools_on_SCHNAM", using: :btree
  add_index "portal_nces06_schools", ["SEASCH"], name: "index_portal_nces06_schools_on_SEASCH", using: :btree
  add_index "portal_nces06_schools", ["STID"], name: "index_portal_nces06_schools_on_STID", using: :btree
  add_index "portal_nces06_schools", ["nces_district_id"], name: "index_portal_nces06_schools_on_nces_district_id", using: :btree

  create_table "portal_offering_activity_feedbacks", force: :cascade do |t|
    t.boolean  "enable_text_feedback",               default: false
    t.integer  "max_score",            limit: 4,     default: 10
    t.string   "score_type",           limit: 255,   default: "none"
    t.integer  "activity_id",          limit: 4
    t.integer  "portal_offering_id",   limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "use_rubric"
    t.text     "rubric",               limit: 65535
  end

  create_table "portal_offering_embeddable_metadata", force: :cascade do |t|
    t.integer  "offering_id",          limit: 4
    t.integer  "embeddable_id",        limit: 4
    t.string   "embeddable_type",      limit: 255
    t.boolean  "enable_score",                     default: false
    t.integer  "max_score",            limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "enable_text_feedback",             default: false
  end

  add_index "portal_offering_embeddable_metadata", ["offering_id", "embeddable_id", "embeddable_type"], name: "index_portal_offering_metadata", unique: true, using: :btree

  create_table "portal_offerings", force: :cascade do |t|
    t.string   "uuid",             limit: 36
    t.string   "status",           limit: 255
    t.integer  "clazz_id",         limit: 4
    t.integer  "runnable_id",      limit: 4
    t.string   "runnable_type",    limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "active",                       default: true
    t.boolean  "default_offering",             default: false
    t.integer  "position",         limit: 4,   default: 0
    t.boolean  "anonymous_report",             default: false
    t.boolean  "locked",                       default: false
  end

  add_index "portal_offerings", ["clazz_id"], name: "index_portal_offerings_on_clazz_id", using: :btree
  add_index "portal_offerings", ["runnable_id"], name: "index_portal_offerings_on_runnable_id", using: :btree
  add_index "portal_offerings", ["runnable_type"], name: "index_portal_offerings_on_runnable_type", using: :btree

  create_table "portal_permission_forms", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "project_id", limit: 4
  end

  create_table "portal_school_memberships", force: :cascade do |t|
    t.string   "uuid",        limit: 36
    t.string   "name",        limit: 255
    t.text     "description", limit: 16777215
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "member_id",   limit: 4
    t.string   "member_type", limit: 255
    t.integer  "school_id",   limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "portal_school_memberships", ["member_type", "member_id"], name: "member_type_id_index", using: :btree
  add_index "portal_school_memberships", ["school_id", "member_id", "member_type"], name: "school_memberships_long_idx", using: :btree

  create_table "portal_schools", force: :cascade do |t|
    t.string   "uuid",           limit: 36
    t.string   "name",           limit: 255
    t.text     "description",    limit: 16777215
    t.integer  "district_id",    limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "nces_school_id", limit: 4
    t.string   "state",          limit: 80
    t.string   "zipcode",        limit: 20
    t.string   "ncessch",        limit: 12
    t.integer  "country_id",     limit: 4
    t.text     "city",           limit: 16777215
  end

  add_index "portal_schools", ["country_id"], name: "index_portal_schools_on_country_id", using: :btree
  add_index "portal_schools", ["district_id"], name: "index_portal_schools_on_district_id", using: :btree
  add_index "portal_schools", ["name"], name: "index_portal_schools_on_name", using: :btree
  add_index "portal_schools", ["nces_school_id"], name: "index_portal_schools_on_nces_school_id", using: :btree
  add_index "portal_schools", ["state"], name: "index_portal_schools_on_state", using: :btree

  create_table "portal_student_clazzes", force: :cascade do |t|
    t.string   "uuid",        limit: 36
    t.string   "name",        limit: 255
    t.text     "description", limit: 16777215
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "clazz_id",    limit: 4
    t.integer  "student_id",  limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "portal_student_clazzes", ["clazz_id"], name: "index_portal_student_clazzes_on_clazz_id", using: :btree
  add_index "portal_student_clazzes", ["student_id", "clazz_id"], name: "student_class_index", using: :btree

  create_table "portal_student_permission_forms", force: :cascade do |t|
    t.boolean  "signed"
    t.integer  "portal_student_id",         limit: 4
    t.integer  "portal_permission_form_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "portal_student_permission_forms", ["portal_permission_form_id"], name: "p_s_p_form_id", using: :btree
  add_index "portal_student_permission_forms", ["portal_student_id"], name: "index_portal_student_permission_forms_on_portal_student_id", using: :btree

  create_table "portal_students", force: :cascade do |t|
    t.string   "uuid",           limit: 36
    t.integer  "user_id",        limit: 4
    t.integer  "grade_level_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "portal_students", ["user_id"], name: "index_portal_students_on_user_id", using: :btree

  create_table "portal_subjects", force: :cascade do |t|
    t.string   "uuid",        limit: 36
    t.string   "name",        limit: 255
    t.text     "description", limit: 16777215
    t.integer  "teacher_id",  limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "portal_teacher_clazzes", force: :cascade do |t|
    t.string   "uuid",        limit: 36
    t.string   "name",        limit: 255
    t.text     "description", limit: 16777215
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "clazz_id",    limit: 4
    t.integer  "teacher_id",  limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "active",                       default: true
    t.integer  "position",    limit: 4,        default: 0
  end

  add_index "portal_teacher_clazzes", ["clazz_id"], name: "index_portal_teacher_clazzes_on_clazz_id", using: :btree
  add_index "portal_teacher_clazzes", ["teacher_id"], name: "index_portal_teacher_clazzes_on_teacher_id", using: :btree

  create_table "portal_teacher_full_status", force: :cascade do |t|
    t.integer "offering_id",        limit: 4
    t.integer "teacher_id",         limit: 4
    t.boolean "offering_collapsed"
  end

  add_index "portal_teacher_full_status", ["offering_id"], name: "index_portal_teacher_full_status_on_offering_id", using: :btree
  add_index "portal_teacher_full_status", ["teacher_id"], name: "index_portal_teacher_full_status_on_teacher_id", using: :btree

  create_table "portal_teachers", force: :cascade do |t|
    t.string   "uuid",                   limit: 36
    t.integer  "user_id",                limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "offerings_count",        limit: 4,  default: 0
    t.integer  "left_pane_submenu_item", limit: 4
  end

  add_index "portal_teachers", ["user_id"], name: "index_portal_teachers_on_user_id", using: :btree

  create_table "report_embeddable_filters", force: :cascade do |t|
    t.integer  "offering_id", limit: 4
    t.text     "embeddables", limit: 16777215
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "ignore"
  end

  add_index "report_embeddable_filters", ["offering_id"], name: "index_report_embeddable_filters_on_offering_id", using: :btree

  create_table "report_learner_activity", force: :cascade do |t|
    t.integer "learner_id",       limit: 4
    t.integer "activity_id",      limit: 4
    t.float   "complete_percent", limit: 24
  end

  add_index "report_learner_activity", ["activity_id"], name: "index_report_learner_activity_on_activity_id", using: :btree
  add_index "report_learner_activity", ["learner_id"], name: "index_report_learner_activity_on_learner_id", using: :btree

  create_table "report_learners", force: :cascade do |t|
    t.integer  "learner_id",           limit: 4
    t.integer  "student_id",           limit: 4
    t.integer  "user_id",              limit: 4
    t.integer  "offering_id",          limit: 4
    t.integer  "class_id",             limit: 4
    t.datetime "last_run"
    t.datetime "last_report"
    t.string   "offering_name",        limit: 255
    t.string   "teachers_name",        limit: 255
    t.string   "student_name",         limit: 255
    t.string   "username",             limit: 255
    t.string   "school_name",          limit: 255
    t.string   "class_name",           limit: 255
    t.integer  "runnable_id",          limit: 4
    t.string   "runnable_name",        limit: 255
    t.integer  "school_id",            limit: 4
    t.integer  "num_answerables",      limit: 4
    t.integer  "num_answered",         limit: 4
    t.integer  "num_correct",          limit: 4
    t.text     "answers",              limit: 4294967295
    t.string   "runnable_type",        limit: 255
    t.float    "complete_percent",     limit: 24
    t.text     "permission_forms",     limit: 16777215
    t.integer  "num_submitted",        limit: 4
    t.string   "teachers_district",    limit: 255
    t.string   "teachers_state",       limit: 255
    t.string   "teachers_email",       limit: 255
    t.string   "permission_forms_id",  limit: 255
    t.string   "teachers_id",          limit: 255
    t.text     "teachers_map",         limit: 65535
    t.text     "permission_forms_map", limit: 65535
  end

  add_index "report_learners", ["class_id"], name: "index_report_learners_on_class_id", using: :btree
  add_index "report_learners", ["last_run"], name: "index_report_learners_on_last_run", using: :btree
  add_index "report_learners", ["learner_id"], name: "index_report_learners_on_learner_id", using: :btree
  add_index "report_learners", ["offering_id"], name: "index_report_learners_on_offering_id", using: :btree
  add_index "report_learners", ["runnable_id", "runnable_type"], name: "index_report_learners_on_runnable_id_and_runnable_type", using: :btree
  add_index "report_learners", ["runnable_id"], name: "index_report_learners_on_runnable_id", using: :btree
  add_index "report_learners", ["school_id"], name: "index_report_learners_on_school_id", using: :btree
  add_index "report_learners", ["student_id"], name: "index_report_learners_on_student_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string  "title",    limit: 255
    t.integer "position", limit: 4
    t.string  "uuid",     limit: 36
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id", limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "roles_users", ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", using: :btree
  add_index "roles_users", ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", using: :btree

  create_table "saveable_external_link_urls", force: :cascade do |t|
    t.integer  "external_link_id",  limit: 4
    t.integer  "bundle_content_id", limit: 4
    t.integer  "position",          limit: 4
    t.text     "url",               limit: 65535
    t.boolean  "is_final"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.text     "feedback",          limit: 65535
    t.boolean  "has_been_reviewed",               default: false
    t.integer  "score",             limit: 4
  end

  add_index "saveable_external_link_urls", ["external_link_id"], name: "index_saveable_external_link_urls_on_external_link_id", using: :btree

  create_table "saveable_external_links", force: :cascade do |t|
    t.integer  "embeddable_id",   limit: 4
    t.string   "embeddable_type", limit: 255
    t.integer  "learner_id",      limit: 4
    t.integer  "offering_id",     limit: 4
    t.integer  "response_count",  limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "saveable_external_links", ["embeddable_id", "embeddable_type"], name: "svbl_xtrn_links_poly", using: :btree
  add_index "saveable_external_links", ["learner_id"], name: "index_saveable_external_links_on_learner_id", using: :btree
  add_index "saveable_external_links", ["offering_id"], name: "index_saveable_external_links_on_offering_id", using: :btree

  create_table "saveable_image_question_answers", force: :cascade do |t|
    t.integer  "image_question_id", limit: 4
    t.integer  "bundle_content_id", limit: 4
    t.integer  "blob_id",           limit: 4
    t.integer  "position",          limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.text     "note",              limit: 16777215
    t.string   "uuid",              limit: 36
    t.boolean  "is_final"
    t.text     "feedback",          limit: 65535
    t.boolean  "has_been_reviewed",                  default: false
    t.integer  "score",             limit: 4
  end

  add_index "saveable_image_question_answers", ["image_question_id", "position"], name: "i_q_id_and_position_index", using: :btree

  create_table "saveable_image_questions", force: :cascade do |t|
    t.integer  "learner_id",        limit: 4
    t.integer  "offering_id",       limit: 4
    t.integer  "image_question_id", limit: 4
    t.integer  "response_count",    limit: 4,  default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "uuid",              limit: 36
  end

  add_index "saveable_image_questions", ["image_question_id"], name: "index_saveable_image_questions_on_image_question_id", using: :btree
  add_index "saveable_image_questions", ["learner_id"], name: "index_saveable_image_questions_on_learner_id", using: :btree
  add_index "saveable_image_questions", ["offering_id"], name: "index_saveable_image_questions_on_offering_id", using: :btree

  create_table "saveable_interactive_states", force: :cascade do |t|
    t.integer  "interactive_id",    limit: 4
    t.integer  "bundle_content_id", limit: 4
    t.integer  "position",          limit: 4
    t.text     "state",             limit: 4294967295
    t.boolean  "is_final"
    t.text     "feedback",          limit: 65535
    t.boolean  "has_been_reviewed",                    default: false
    t.integer  "score",             limit: 4
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "saveable_interactive_states", ["interactive_id", "position"], name: "inter_id_and_position_index", using: :btree

  create_table "saveable_interactives", force: :cascade do |t|
    t.integer  "learner_id",     limit: 4
    t.integer  "offering_id",    limit: 4
    t.integer  "response_count", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "iframe_id",      limit: 4
  end

  create_table "saveable_multiple_choice_answers", force: :cascade do |t|
    t.integer  "multiple_choice_id", limit: 4
    t.integer  "bundle_content_id",  limit: 4
    t.integer  "position",           limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "uuid",               limit: 36
    t.boolean  "is_final"
    t.text     "feedback",           limit: 65535
    t.boolean  "has_been_reviewed",                default: false
    t.integer  "score",              limit: 4
  end

  add_index "saveable_multiple_choice_answers", ["multiple_choice_id", "position"], name: "m_c_id_and_position_index", using: :btree

  create_table "saveable_multiple_choice_rationale_choices", force: :cascade do |t|
    t.integer  "choice_id",  limit: 4
    t.integer  "answer_id",  limit: 4
    t.string   "rationale",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "uuid",       limit: 36
  end

  add_index "saveable_multiple_choice_rationale_choices", ["answer_id"], name: "index_saveable_multiple_choice_rationale_choices_on_answer_id", using: :btree
  add_index "saveable_multiple_choice_rationale_choices", ["choice_id"], name: "index_saveable_multiple_choice_rationale_choices_on_choice_id", using: :btree

  create_table "saveable_multiple_choices", force: :cascade do |t|
    t.integer  "learner_id",         limit: 4
    t.integer  "multiple_choice_id", limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "offering_id",        limit: 4
    t.integer  "response_count",     limit: 4,  default: 0
    t.string   "uuid",               limit: 36
  end

  add_index "saveable_multiple_choices", ["learner_id"], name: "index_saveable_multiple_choices_on_learner_id", using: :btree
  add_index "saveable_multiple_choices", ["multiple_choice_id"], name: "index_saveable_multiple_choices_on_multiple_choice_id", using: :btree
  add_index "saveable_multiple_choices", ["offering_id"], name: "index_saveable_multiple_choices_on_offering_id", using: :btree

  create_table "saveable_open_response_answers", force: :cascade do |t|
    t.integer  "open_response_id",  limit: 4
    t.integer  "bundle_content_id", limit: 4
    t.integer  "position",          limit: 4
    t.text     "answer",            limit: 16777215
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "is_final"
    t.text     "feedback",          limit: 65535
    t.boolean  "has_been_reviewed",                  default: false
    t.integer  "score",             limit: 4
  end

  add_index "saveable_open_response_answers", ["open_response_id", "position"], name: "o_r_id_and_position_index", using: :btree

  create_table "saveable_open_responses", force: :cascade do |t|
    t.integer  "learner_id",       limit: 4
    t.integer  "open_response_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "offering_id",      limit: 4
    t.integer  "response_count",   limit: 4, default: 0
  end

  add_index "saveable_open_responses", ["learner_id"], name: "index_saveable_open_responses_on_learner_id", using: :btree
  add_index "saveable_open_responses", ["offering_id"], name: "index_saveable_open_responses_on_offering_id", using: :btree
  add_index "saveable_open_responses", ["open_response_id"], name: "index_saveable_open_responses_on_open_response_id", using: :btree

  create_table "saveable_sparks_measuring_resistance", force: :cascade do |t|
    t.integer  "learner_id",  limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "offering_id", limit: 4
  end

  add_index "saveable_sparks_measuring_resistance", ["learner_id"], name: "index_saveable_sparks_measuring_resistance_on_learner_id", using: :btree
  add_index "saveable_sparks_measuring_resistance", ["offering_id"], name: "index_saveable_sparks_measuring_resistance_on_offering_id", using: :btree

  create_table "saveable_sparks_measuring_resistance_reports", force: :cascade do |t|
    t.integer  "measuring_resistance_id", limit: 4
    t.integer  "position",                limit: 4
    t.text     "content",                 limit: 16777215
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "sections", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.integer  "activity_id",        limit: 4
    t.string   "uuid",               limit: 36
    t.string   "name",               limit: 255
    t.text     "description",        limit: 16777215
    t.integer  "position",           limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "teacher_only",                        default: false
    t.string   "publication_status", limit: 255
  end

  add_index "sections", ["activity_id", "position"], name: "index_sections_on_activity_id_and_position", using: :btree
  add_index "sections", ["position"], name: "index_sections_on_position", using: :btree

  create_table "security_questions", force: :cascade do |t|
    t.integer "user_id",  limit: 4,   null: false
    t.string  "question", limit: 100, null: false
    t.string  "answer",   limit: 100, null: false
  end

  add_index "security_questions", ["user_id"], name: "index_security_questions_on_user_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,      null: false
    t.text     "data",       limit: 16777215
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "standard_documents", force: :cascade do |t|
    t.string   "uri",          limit: 255
    t.string   "jurisdiction", limit: 255
    t.string   "title",        limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "standard_documents", ["name"], name: "index_standard_documents_on_name", unique: true, using: :btree

  create_table "standard_statements", force: :cascade do |t|
    t.string   "uri",                limit: 255
    t.string   "doc",                limit: 255
    t.string   "statement_notation", limit: 255
    t.string   "statement_label",    limit: 255
    t.text     "description",        limit: 65535
    t.text     "parents",            limit: 65535
    t.string   "material_type",      limit: 255
    t.integer  "material_id",        limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "education_level",    limit: 255
    t.boolean  "is_leaf"
  end

  add_index "standard_statements", ["uri", "material_type", "material_id"], name: "standard_unique", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "taggable_type", limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "teacher_project_views", force: :cascade do |t|
    t.integer  "viewed_project_id", limit: 4, null: false
    t.integer  "teacher_id",        limit: 4, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "teacher_project_views", ["teacher_id"], name: "index_teacher_project_views_on_teacher_id", using: :btree

  create_table "tools", force: :cascade do |t|
    t.string "name",        limit: 255
    t.string "source_type", limit: 255
    t.text   "tool_id",     limit: 65535
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                       limit: 40
    t.string   "first_name",                  limit: 100, default: ""
    t.string   "last_name",                   limit: 100, default: ""
    t.string   "email",                       limit: 128, default: "",        null: false
    t.string   "encrypted_password",          limit: 128, default: "",        null: false
    t.string   "password_salt",               limit: 255, default: "",        null: false
    t.string   "remember_token",              limit: 255
    t.string   "confirmation_token",          limit: 255
    t.string   "state",                       limit: 255, default: "passive", null: false
    t.datetime "remember_created_at"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.string   "uuid",                        limit: 36
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.boolean  "default_user",                            default: false
    t.boolean  "site_admin",                              default: false
    t.string   "external_id",                 limit: 255
    t.boolean  "require_password_reset",                  default: false
    t.boolean  "of_consenting_age",                       default: false
    t.boolean  "have_consent",                            default: false
    t.boolean  "asked_age",                               default: false
    t.string   "reset_password_token",        limit: 255
    t.integer  "sign_in_count",               limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",          limit: 255
    t.string   "last_sign_in_ip",             limit: 255
    t.string   "unconfirmed_email",           limit: 255
    t.datetime "confirmation_sent_at"
    t.boolean  "require_portal_user_type",                default: false
    t.string   "sign_up_path",                limit: 255
    t.boolean  "email_subscribed",                        default: false
    t.boolean  "can_add_teachers_to_cohorts",             default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["id"], name: "index_users_on_id_and_type", using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

end
