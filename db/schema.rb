# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110616195327) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",               :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_template"
    t.integer  "position"
    t.integer  "investigation_id"
    t.integer  "original_id"
    t.boolean  "teacher_only",                     :default => false
    t.string   "publication_status"
    t.integer  "offerings_count",                  :default => 0
  end

  add_index "activities", ["investigation_id", "position"], :name => "index_activities_on_investigation_id_and_position"

  create_table "admin_project_vendor_interfaces", :force => true do |t|
    t.integer  "admin_project_id"
    t.integer  "probe_vendor_interface_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_projects", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.text     "states_and_provinces"
    t.integer  "maven_jnlp_server_id"
    t.integer  "maven_jnlp_family_id"
    t.string   "jnlp_version_str"
    t.boolean  "snapshot_enabled"
    t.boolean  "enable_default_users"
    t.string   "uuid",                           :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "home_page_content"
    t.boolean  "use_student_security_questions",               :default => false
    t.boolean  "allow_default_class"
    t.boolean  "enable_grade_levels",                          :default => false
    t.text     "custom_css"
    t.boolean  "use_bitmap_snapshots",                         :default => false
  end

  create_table "attached_files", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "author_notes", :force => true do |t|
    t.text     "body"
    t.string   "uuid",                 :limit => 36
    t.integer  "authored_entity_id"
    t.string   "authored_entity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "bj_config", :primary_key => "bj_config_id", :force => true do |t|
    t.text "hostname"
    t.text "key"
    t.text "value"
    t.text "cast"
  end

  create_table "bj_job", :primary_key => "bj_job_id", :force => true do |t|
    t.text     "command"
    t.text     "state"
    t.integer  "priority"
    t.text     "tag"
    t.integer  "is_restartable"
    t.text     "submitter"
    t.text     "runner"
    t.integer  "pid"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "env"
    t.text     "stdin"
    t.text     "stdout"
    t.text     "stderr"
    t.integer  "exit_status"
  end

  create_table "bj_job_archive", :primary_key => "bj_job_archive_id", :force => true do |t|
    t.text     "command"
    t.text     "state"
    t.integer  "priority"
    t.text     "tag"
    t.integer  "is_restartable"
    t.text     "submitter"
    t.text     "runner"
    t.integer  "pid"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.text     "env"
    t.text     "stdin"
    t.text     "stdout"
    t.text     "stderr"
    t.integer  "exit_status"
  end

  create_table "collaborations", :force => true do |t|
    t.integer  "bundle_content_id"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dataservice_blobs", :force => true do |t|
    t.binary   "content",           :limit => 16777215
    t.string   "token"
    t.integer  "bundle_content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dataservice_blobs", ["bundle_content_id"], :name => "index_dataservice_blobs_on_bundle_content_id"

  create_table "dataservice_bundle_contents", :force => true do |t|
    t.integer  "bundle_logger_id"
    t.integer  "position"
    t.text     "body",             :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "otml",             :limit => 2147483647
    t.boolean  "processed"
    t.boolean  "valid_xml",                              :default => false
    t.boolean  "empty",                                  :default => true
    t.string   "uuid",             :limit => 36
    t.text     "original_body"
  end

  add_index "dataservice_bundle_contents", ["bundle_logger_id"], :name => "index_dataservice_bundle_contents_on_bundle_logger_id"

  create_table "dataservice_bundle_loggers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "in_progress_bundle_id"
  end

  create_table "dataservice_console_contents", :force => true do |t|
    t.integer  "console_logger_id"
    t.integer  "position"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dataservice_console_loggers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_breed_offsprings", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",               :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "width"
    t.integer  "height"
    t.integer  "mother_organism_id"
    t.integer  "father_organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_chromosome_zooms", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                                     :limit => 36
    t.string   "name"
    t.text     "description"
    t.boolean  "chromosome_a_visible"
    t.boolean  "chromosome_b_visible"
    t.integer  "chromosome_position_in_base_pairs"
    t.float    "chromosome_position_in_cm"
    t.boolean  "draw_crossover"
    t.boolean  "draw_genes"
    t.boolean  "draw_markers"
    t.boolean  "draw_tracks"
    t.string   "g_browse_url_template"
    t.boolean  "image_label_characteristics_text_visible"
    t.boolean  "image_label_lock_symbol_visible"
    t.boolean  "image_label_name_text_visible"
    t.boolean  "image_label_sex_text_visible"
    t.integer  "image_label_size"
    t.boolean  "image_label_species_text_visible"
    t.integer  "organism_label_type"
    t.integer  "zoom_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_chromosome_zooms_organisms", :id => false, :force => true do |t|
    t.integer  "chromosome_zoom_id"
    t.integer  "organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_chromosomes", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "organism_id"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_meiosis_views", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                         :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "width"
    t.integer  "height"
    t.boolean  "replay_button_enabled"
    t.boolean  "controlled_crossover_enabled"
    t.boolean  "crossover_control_visible"
    t.boolean  "controlled_alignment_enabled"
    t.boolean  "alignment_control_visible"
    t.integer  "father_organism_id"
    t.integer  "mother_organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_multiple_organisms", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "width"
    t.integer  "height"
    t.integer  "organism_image_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_multiple_organisms_organisms", :id => false, :force => true do |t|
    t.integer  "multiple_organism_id"
    t.integer  "organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_organisms", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                  :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "sex"
    t.string   "alleles"
    t.string   "strain"
    t.integer  "chromosomes_color"
    t.boolean  "fatal_characteristics"
    t.integer  "world_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_organisms_pedigrees", :id => false, :force => true do |t|
    t.integer  "pedigree_id"
    t.integer  "organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_pedigrees", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                    :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "height"
    t.integer  "width"
    t.boolean  "crossover_enabled"
    t.boolean  "sex_text_visible"
    t.boolean  "organism_images_visible"
    t.boolean  "top_controls_visible"
    t.boolean  "reset_button_visible"
    t.integer  "organism_image_size"
    t.integer  "minimum_number_children"
    t.integer  "maximum_number_children"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_static_organisms", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_biologica_worlds", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",         :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "species_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_data_collectors", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "probe_type_id"
    t.integer  "user_id"
    t.string   "uuid",                       :limit => 36
    t.string   "title"
    t.float    "y_axis_min",                               :default => 0.0
    t.float    "y_axis_max",                               :default => 5.0
    t.float    "x_axis_min"
    t.float    "x_axis_max"
    t.string   "x_axis_label",                             :default => "Time"
    t.string   "x_axis_units",                             :default => "s"
    t.string   "y_axis_label"
    t.string   "y_axis_units"
    t.boolean  "multiple_graphable_enabled",               :default => false
    t.boolean  "draw_marks",                               :default => false
    t.boolean  "connect_points",                           :default => true
    t.boolean  "autoscale_enabled",                        :default => false
    t.boolean  "ruler_enabled",                            :default => false
    t.boolean  "show_tare",                                :default => false
    t.boolean  "single_value",                             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "graph_type_id"
    t.integer  "prediction_graph_id"
    t.text     "otml_root_content"
    t.text     "otml_library_content"
    t.text     "data_store_values"
    t.integer  "calibration_id"
    t.boolean  "static"
    t.boolean  "time_limit_status",                        :default => false
    t.float    "time_limit_seconds"
    t.integer  "data_table_id"
    t.boolean  "is_digital_display",                       :default => false
  end

  create_table "embeddable_data_tables", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",              :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "column_count"
    t.integer  "visible_rows"
    t.text     "column_names"
    t.text     "column_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_collector_id"
    t.integer  "precision",                       :default => 2
    t.integer  "width",                           :default => 1200
    t.boolean  "is_numeric",                      :default => true
  end

  create_table "embeddable_drawing_tools", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                 :limit => 36
    t.string   "name"
    t.text     "description"
    t.string   "background_image_url"
    t.string   "stamps"
    t.boolean  "is_grid_visible"
    t.integer  "preferred_width"
    t.integer  "preferred_height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_image_questions", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",       :limit => 36
    t.string   "name"
    t.text     "prompt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_inner_page_pages", :force => true do |t|
    t.integer  "inner_page_id"
    t.integer  "page_id"
    t.integer  "user_id"
    t.string   "uuid",          :limit => 36
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "embeddable_inner_page_pages", ["inner_page_id"], :name => "index_inner_page_pages_on_inner_page_id"
  add_index "embeddable_inner_page_pages", ["page_id"], :name => "index_inner_page_pages_on_page_id"
  add_index "embeddable_inner_page_pages", ["position"], :name => "index_inner_page_pages_on_position"

  create_table "embeddable_inner_pages", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",           :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "static_page_id"
  end

  create_table "embeddable_lab_book_snapshots", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "target_element_type"
    t.integer  "target_element_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_multiple_choice_choices", :force => true do |t|
    t.text     "choice"
    t.integer  "multiple_choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_correct"
  end

  add_index "embeddable_multiple_choice_choices", ["multiple_choice_id"], :name => "index_embeddable_multiple_choice_choices_on_multiple_choice_id"

  create_table "embeddable_multiple_choices", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "prompt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_mw_modeler_pages", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",              :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "authored_data_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_n_logo_models", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",              :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "authored_data_url"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_open_responses", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",             :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "prompt"
    t.string   "default_response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rows",                           :default => 5
    t.integer  "columns",                        :default => 32
    t.integer  "font_size",                      :default => 12
  end

  create_table "embeddable_raw_otmls", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",         :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "otml_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_smartgraph_range_questions", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                                 :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "data_collector_id"
    t.integer  "correct_range_min"
    t.integer  "correct_range_max"
    t.string   "correct_range_axis"
    t.integer  "highlight_range_min"
    t.integer  "highlight_range_max"
    t.string   "highlight_range_axis"
    t.text     "prompt"
    t.string   "answer_style"
    t.text     "no_answer_response_text"
    t.boolean  "no_answer_highlight"
    t.text     "correct_response_text"
    t.boolean  "correct_highlight"
    t.text     "first_wrong_answer_response_text"
    t.boolean  "first_wrong_highlight"
    t.text     "second_wrong_answer_response_text"
    t.boolean  "second_wrong_highlight"
    t.text     "multiple_wrong_answers_response_text"
    t.boolean  "multiple_wrong_highlight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_sound_graphers", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",       :limit => 36
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_video_players", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.string   "image_url"
    t.string   "video_url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "embeddable_xhtmls", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "name"
    t.text     "description"
    t.text     "url"
    t.string   "publication_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offerings_count",    :default => 0
    t.string   "save_path"
  end

  add_index "external_activities", ["save_path"], :name => "index_external_activities_on_save_path"

  create_table "external_user_domains", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "server_url"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "description"
    t.string   "uuid",         :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "investigations", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                      :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grade_span_expectation_id"
    t.boolean  "teacher_only",                            :default => false
    t.string   "publication_status"
    t.integer  "offerings_count",                         :default => 0
  end

  create_table "jars_versioned_jnlps", :id => false, :force => true do |t|
    t.integer "jar_id"
    t.integer "versioned_jnlp_id"
  end

  create_table "maven_jnlp_icons", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "href"
    t.integer  "height"
    t.integer  "width"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maven_jnlp_jars", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.boolean  "main"
    t.string   "os"
    t.string   "href"
    t.integer  "size"
    t.integer  "size_pack_gz"
    t.boolean  "signature_verified"
    t.string   "version_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maven_jnlp_maven_jnlp_families", :force => true do |t|
    t.integer  "maven_jnlp_server_id"
    t.string   "uuid"
    t.string   "name"
    t.string   "snapshot_version"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maven_jnlp_maven_jnlp_servers", :force => true do |t|
    t.string   "uuid"
    t.string   "host"
    t.string   "path"
    t.string   "name"
    t.string   "local_cache_dir"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maven_jnlp_native_libraries", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.boolean  "main"
    t.string   "os"
    t.string   "href"
    t.integer  "size"
    t.integer  "size_pack_gz"
    t.boolean  "signature_verified"
    t.string   "version_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maven_jnlp_properties", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "value"
    t.string   "os"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maven_jnlp_versioned_jnlp_urls", :force => true do |t|
    t.string  "uuid"
    t.integer "maven_jnlp_family_id"
    t.string  "path"
    t.string  "url"
    t.string  "version_str"
    t.string  "date_str",             :limit => 15
  end

  add_index "maven_jnlp_versioned_jnlp_urls", ["date_str"], :name => "index_maven_jnlp_versioned_jnlp_urls_on_date_str"
  add_index "maven_jnlp_versioned_jnlp_urls", ["maven_jnlp_family_id"], :name => "index_maven_jnlp_versioned_jnlp_urls_on_maven_jnlp_family_id"
  add_index "maven_jnlp_versioned_jnlp_urls", ["version_str"], :name => "index_maven_jnlp_versioned_jnlp_urls_on_version_str"

  create_table "maven_jnlp_versioned_jnlps", :force => true do |t|
    t.integer  "versioned_jnlp_url_id"
    t.integer  "jnlp_icon_id"
    t.string   "uuid"
    t.string   "name"
    t.string   "main_class"
    t.string   "argument"
    t.boolean  "offline_allowed"
    t.boolean  "local_resource_signatures_verified"
    t.boolean  "include_pack_gzip"
    t.string   "spec"
    t.string   "codebase"
    t.string   "href"
    t.string   "j2se_version"
    t.integer  "max_heap_size"
    t.integer  "initial_heap_size"
    t.string   "title"
    t.string   "vendor"
    t.string   "homepage"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "native_libraries_versioned_jnlps", :id => false, :force => true do |t|
    t.integer "native_library_id"
    t.integer "versioned_jnlp_id"
  end

  create_table "otml_categories_otrunk_imports", :id => false, :force => true do |t|
    t.integer "otml_category_id"
    t.integer "otrunk_import_id"
  end

  add_index "otml_categories_otrunk_imports", ["otml_category_id", "otrunk_import_id"], :name => "otc_oti", :unique => true

  create_table "otml_files_otrunk_imports", :id => false, :force => true do |t|
    t.integer "otml_file_id"
    t.integer "otrunk_import_id"
  end

  add_index "otml_files_otrunk_imports", ["otml_file_id", "otrunk_import_id"], :name => "otf_oti", :unique => true

  create_table "otml_files_otrunk_view_entries", :id => false, :force => true do |t|
    t.integer "otml_file_id"
    t.integer "otrunk_view_entry_id"
  end

  add_index "otml_files_otrunk_view_entries", ["otml_file_id", "otrunk_view_entry_id"], :name => "otf_otve", :unique => true

  create_table "otrunk_example_otml_categories", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "otrunk_example_otml_categories", ["name"], :name => "index_otrunk_example_otml_categories_on_name", :unique => true

  create_table "otrunk_example_otml_files", :force => true do |t|
    t.string   "uuid"
    t.integer  "otml_category_id"
    t.string   "name"
    t.string   "path"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "otrunk_example_otml_files", ["otml_category_id"], :name => "index_otrunk_example_otml_files_on_otml_category_id"
  add_index "otrunk_example_otml_files", ["path"], :name => "index_otrunk_example_otml_files_on_path", :unique => true

  create_table "otrunk_example_otrunk_imports", :force => true do |t|
    t.string   "uuid"
    t.string   "classname"
    t.string   "fq_classname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "otrunk_example_otrunk_imports", ["fq_classname"], :name => "index_otrunk_example_otrunk_imports_on_fq_classname", :unique => true

  create_table "otrunk_example_otrunk_view_entries", :force => true do |t|
    t.string   "uuid"
    t.integer  "otrunk_import_id"
    t.string   "classname"
    t.string   "fq_classname"
    t.boolean  "standard_view"
    t.boolean  "standard_edit_view"
    t.boolean  "edit_view"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "otrunk_example_otrunk_view_entries", ["fq_classname"], :name => "index_otrunk_example_otrunk_view_entries_on_fq_classname", :unique => true

  create_table "page_elements", :force => true do |t|
    t.integer  "page_id"
    t.integer  "embeddable_id"
    t.string   "embeddable_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "page_elements", ["embeddable_id"], :name => "index_page_elements_on_embeddable_id"
  add_index "page_elements", ["page_id"], :name => "index_page_elements_on_page_id"
  add_index "page_elements", ["position"], :name => "index_page_elements_on_position"

  create_table "pages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "section_id"
    t.string   "uuid",               :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "teacher_only",                     :default => false
    t.string   "publication_status"
    t.integer  "offerings_count",                  :default => 0
  end

  add_index "pages", ["position"], :name => "index_pages_on_position"
  add_index "pages", ["section_id", "position"], :name => "index_pages_on_section_id_and_position"

  create_table "passwords", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_code"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portal_clazzes", :force => true do |t|
    t.string   "uuid",          :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "class_word"
    t.string   "status"
    t.integer  "course_id"
    t.integer  "semester_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "section"
    t.boolean  "default_class",               :default => false
  end

  add_index "portal_clazzes", ["class_word"], :name => "index_portal_clazzes_on_class_word"

  create_table "portal_courses", :force => true do |t|
    t.string   "uuid",          :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "school_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "course_number"
  end

  add_index "portal_courses", ["course_number"], :name => "index_portal_courses_on_course_number"
  add_index "portal_courses", ["name"], :name => "index_portal_courses_on_name"
  add_index "portal_courses", ["school_id"], :name => "index_portal_courses_on_school_id"

  create_table "portal_courses_grade_levels", :id => false, :force => true do |t|
    t.integer  "grade_level_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portal_districts", :force => true do |t|
    t.string   "uuid",             :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nces_district_id"
    t.string   "state",            :limit => 2
    t.string   "leaid",            :limit => 7
    t.string   "zipcode",          :limit => 5
  end

  add_index "portal_districts", ["state"], :name => "index_portal_districts_on_state"

  create_table "portal_grade_levels", :force => true do |t|
    t.string   "uuid",                  :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "has_grade_levels_id"
    t.string   "has_grade_levels_type"
    t.integer  "grade_id"
  end

  create_table "portal_grade_levels_teachers", :id => false, :force => true do |t|
    t.integer  "grade_level_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portal_grades", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "position"
    t.string   "uuid"
    t.boolean  "active",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portal_learners", :force => true do |t|
    t.string   "uuid",              :limit => 36
    t.integer  "student_id"
    t.integer  "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bundle_logger_id"
    t.integer  "console_logger_id"
  end

  add_index "portal_learners", ["bundle_logger_id"], :name => "index_portal_learners_on_bundle_logger_id"
  add_index "portal_learners", ["console_logger_id"], :name => "index_portal_learners_on_console_logger_id"
  add_index "portal_learners", ["offering_id"], :name => "index_portal_learners_on_offering_id"

  create_table "portal_nces06_districts", :force => true do |t|
    t.string  "LEAID",  :limit => 7
    t.string  "FIPST",  :limit => 2
    t.string  "STID",   :limit => 14
    t.string  "NAME",   :limit => 60
    t.string  "PHONE",  :limit => 10
    t.string  "MSTREE", :limit => 30
    t.string  "MCITY",  :limit => 30
    t.string  "MSTATE", :limit => 2
    t.string  "MZIP",   :limit => 5
    t.string  "MZIP4",  :limit => 4
    t.string  "LSTREE", :limit => 30
    t.string  "LCITY",  :limit => 30
    t.string  "LSTATE", :limit => 2
    t.string  "LZIP",   :limit => 5
    t.string  "LZIP4",  :limit => 4
    t.string  "KIND",   :limit => 1
    t.string  "UNION",  :limit => 3
    t.string  "CONUM",  :limit => 5
    t.string  "CONAME", :limit => 30
    t.string  "CSA",    :limit => 3
    t.string  "CBSA",   :limit => 5
    t.string  "METMIC", :limit => 1
    t.string  "MSC",    :limit => 1
    t.string  "ULOCAL", :limit => 2
    t.string  "CDCODE", :limit => 4
    t.float   "LATCOD"
    t.float   "LONCOD"
    t.string  "BOUND",  :limit => 1
    t.string  "GSLO",   :limit => 2
    t.string  "GSHI",   :limit => 2
    t.string  "AGCHRT", :limit => 1
    t.integer "SCH"
    t.float   "TEACH"
    t.integer "UG"
    t.integer "PK12"
    t.integer "MEMBER"
    t.integer "MIGRNT"
    t.integer "SPECED"
    t.integer "ELL"
    t.float   "PKTCH"
    t.float   "KGTCH"
    t.float   "ELMTCH"
    t.float   "SECTCH"
    t.float   "UGTCH"
    t.float   "TOTTCH"
    t.float   "AIDES"
    t.float   "CORSUP"
    t.float   "ELMGUI"
    t.float   "SECGUI"
    t.float   "TOTGUI"
    t.float   "LIBSPE"
    t.float   "LIBSUP"
    t.float   "LEAADM"
    t.float   "LEASUP"
    t.float   "SCHADM"
    t.float   "SCHSUP"
    t.float   "STUSUP"
    t.float   "OTHSUP"
    t.string  "IGSLO",  :limit => 1
    t.string  "IGSHI",  :limit => 1
    t.string  "ISCH",   :limit => 1
    t.string  "ITEACH", :limit => 1
    t.string  "IUG",    :limit => 1
    t.string  "IPK12",  :limit => 1
    t.string  "IMEMB",  :limit => 1
    t.string  "IMIGRN", :limit => 1
    t.string  "ISPEC",  :limit => 1
    t.string  "IELL",   :limit => 1
    t.string  "IPKTCH", :limit => 1
    t.string  "IKGTCH", :limit => 1
    t.string  "IELTCH", :limit => 1
    t.string  "ISETCH", :limit => 1
    t.string  "IUGTCH", :limit => 1
    t.string  "ITOTCH", :limit => 1
    t.string  "IAIDES", :limit => 1
    t.string  "ICOSUP", :limit => 1
    t.string  "IELGUI", :limit => 1
    t.string  "ISEGUI", :limit => 1
    t.string  "ITOGUI", :limit => 1
    t.string  "ILISPE", :limit => 1
    t.string  "ILISUP", :limit => 1
    t.string  "ILEADM", :limit => 1
    t.string  "ILESUP", :limit => 1
    t.string  "ISCADM", :limit => 1
    t.string  "ISCSUP", :limit => 1
    t.string  "ISTSUP", :limit => 1
    t.string  "IOTSUP", :limit => 1
  end

  add_index "portal_nces06_districts", ["LEAID"], :name => "index_portal_nces06_districts_on_LEAID"
  add_index "portal_nces06_districts", ["NAME"], :name => "index_portal_nces06_districts_on_NAME"
  add_index "portal_nces06_districts", ["STID"], :name => "index_portal_nces06_districts_on_STID"

  create_table "portal_nces06_schools", :force => true do |t|
    t.integer "nces_district_id"
    t.string  "NCESSCH",          :limit => 12
    t.string  "FIPST",            :limit => 2
    t.string  "LEAID",            :limit => 7
    t.string  "SCHNO",            :limit => 5
    t.string  "STID",             :limit => 14
    t.string  "SEASCH",           :limit => 20
    t.string  "LEANM",            :limit => 60
    t.string  "SCHNAM",           :limit => 50
    t.string  "PHONE",            :limit => 10
    t.string  "MSTREE",           :limit => 30
    t.string  "MCITY",            :limit => 30
    t.string  "MSTATE",           :limit => 2
    t.string  "MZIP",             :limit => 5
    t.string  "MZIP4",            :limit => 4
    t.string  "LSTREE",           :limit => 30
    t.string  "LCITY",            :limit => 30
    t.string  "LSTATE",           :limit => 2
    t.string  "LZIP",             :limit => 5
    t.string  "LZIP4",            :limit => 4
    t.string  "KIND",             :limit => 1
    t.string  "STATUS",           :limit => 1
    t.string  "ULOCAL",           :limit => 2
    t.float   "LATCOD"
    t.float   "LONCOD"
    t.string  "CDCODE",           :limit => 4
    t.string  "CONUM",            :limit => 5
    t.string  "CONAME",           :limit => 30
    t.float   "FTE"
    t.string  "GSLO",             :limit => 2
    t.string  "GSHI",             :limit => 2
    t.string  "LEVEL",            :limit => 1
    t.string  "TITLEI",           :limit => 1
    t.string  "STITLI",           :limit => 1
    t.string  "MAGNET",           :limit => 1
    t.string  "CHARTR",           :limit => 1
    t.string  "SHARED",           :limit => 1
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
    t.float   "PUPTCH"
    t.integer "TOTGRD"
    t.string  "IFTE",             :limit => 1
    t.string  "IGSLO",            :limit => 1
    t.string  "IGSHI",            :limit => 1
    t.string  "ITITLI",           :limit => 1
    t.string  "ISTITL",           :limit => 1
    t.string  "IMAGNE",           :limit => 1
    t.string  "ICHART",           :limit => 1
    t.string  "ISHARE",           :limit => 1
    t.string  "IFRELC",           :limit => 1
    t.string  "IREDLC",           :limit => 1
    t.string  "ITOTFR",           :limit => 1
    t.string  "IMIGRN",           :limit => 1
    t.string  "IPK",              :limit => 1
    t.string  "IAMPKM",           :limit => 1
    t.string  "IAMPKF",           :limit => 1
    t.string  "IAMPKU",           :limit => 1
    t.string  "IASPKM",           :limit => 1
    t.string  "IASPKF",           :limit => 1
    t.string  "IASPKU",           :limit => 1
    t.string  "IHIPKM",           :limit => 1
    t.string  "IHIPKF",           :limit => 1
    t.string  "IHIPKU",           :limit => 1
    t.string  "IBLPKM",           :limit => 1
    t.string  "IBLPKF",           :limit => 1
    t.string  "IBLPKU",           :limit => 1
    t.string  "IWHPKM",           :limit => 1
    t.string  "IWHPKF",           :limit => 1
    t.string  "IWHPKU",           :limit => 1
    t.string  "IKG",              :limit => 1
    t.string  "IAMKGM",           :limit => 1
    t.string  "IAMKGF",           :limit => 1
    t.string  "IAMKGU",           :limit => 1
    t.string  "IASKGM",           :limit => 1
    t.string  "IASKGF",           :limit => 1
    t.string  "IASKGU",           :limit => 1
    t.string  "IHIKGM",           :limit => 1
    t.string  "IHIKGF",           :limit => 1
    t.string  "IHIKGU",           :limit => 1
    t.string  "IBLKGM",           :limit => 1
    t.string  "IBLKGF",           :limit => 1
    t.string  "IBLKGU",           :limit => 1
    t.string  "IWHKGM",           :limit => 1
    t.string  "IWHKGF",           :limit => 1
    t.string  "IWHKGU",           :limit => 1
    t.string  "IG01",             :limit => 1
    t.string  "IAM01M",           :limit => 1
    t.string  "IAM01F",           :limit => 1
    t.string  "IAM01U",           :limit => 1
    t.string  "IAS01M",           :limit => 1
    t.string  "IAS01F",           :limit => 1
    t.string  "IAS01U",           :limit => 1
    t.string  "IHI01M",           :limit => 1
    t.string  "IHI01F",           :limit => 1
    t.string  "IHI01U",           :limit => 1
    t.string  "IBL01M",           :limit => 1
    t.string  "IBL01F",           :limit => 1
    t.string  "IBL01U",           :limit => 1
    t.string  "IWH01M",           :limit => 1
    t.string  "IWH01F",           :limit => 1
    t.string  "IWH01U",           :limit => 1
    t.string  "IG02",             :limit => 1
    t.string  "IAM02M",           :limit => 1
    t.string  "IAM02F",           :limit => 1
    t.string  "IAM02U",           :limit => 1
    t.string  "IAS02M",           :limit => 1
    t.string  "IAS02F",           :limit => 1
    t.string  "IAS02U",           :limit => 1
    t.string  "IHI02M",           :limit => 1
    t.string  "IHI02F",           :limit => 1
    t.string  "IHI02U",           :limit => 1
    t.string  "IBL02M",           :limit => 1
    t.string  "IBL02F",           :limit => 1
    t.string  "IBL02U",           :limit => 1
    t.string  "IWH02M",           :limit => 1
    t.string  "IWH02F",           :limit => 1
    t.string  "IWH02U",           :limit => 1
    t.string  "IG03",             :limit => 1
    t.string  "IAM03M",           :limit => 1
    t.string  "IAM03F",           :limit => 1
    t.string  "IAM03U",           :limit => 1
    t.string  "IAS03M",           :limit => 1
    t.string  "IAS03F",           :limit => 1
    t.string  "IAS03U",           :limit => 1
    t.string  "IHI03M",           :limit => 1
    t.string  "IHI03F",           :limit => 1
    t.string  "IHI03U",           :limit => 1
    t.string  "IBL03M",           :limit => 1
    t.string  "IBL03F",           :limit => 1
    t.string  "IBL03U",           :limit => 1
    t.string  "IWH03M",           :limit => 1
    t.string  "IWH03F",           :limit => 1
    t.string  "IWH03U",           :limit => 1
    t.string  "IG04",             :limit => 1
    t.string  "IAM04M",           :limit => 1
    t.string  "IAM04F",           :limit => 1
    t.string  "IAM04U",           :limit => 1
    t.string  "IAS04M",           :limit => 1
    t.string  "IAS04F",           :limit => 1
    t.string  "IAS04U",           :limit => 1
    t.string  "IHI04M",           :limit => 1
    t.string  "IHI04F",           :limit => 1
    t.string  "IHI04U",           :limit => 1
    t.string  "IBL04M",           :limit => 1
    t.string  "IBL04F",           :limit => 1
    t.string  "IBL04U",           :limit => 1
    t.string  "IWH04M",           :limit => 1
    t.string  "IWH04F",           :limit => 1
    t.string  "IWH04U",           :limit => 1
    t.string  "IG05",             :limit => 1
    t.string  "IAM05M",           :limit => 1
    t.string  "IAM05F",           :limit => 1
    t.string  "IAM05U",           :limit => 1
    t.string  "IAS05M",           :limit => 1
    t.string  "IAS05F",           :limit => 1
    t.string  "IAS05U",           :limit => 1
    t.string  "IHI05M",           :limit => 1
    t.string  "IHI05F",           :limit => 1
    t.string  "IHI05U",           :limit => 1
    t.string  "IBL05M",           :limit => 1
    t.string  "IBL05F",           :limit => 1
    t.string  "IBL05U",           :limit => 1
    t.string  "IWH05M",           :limit => 1
    t.string  "IWH05F",           :limit => 1
    t.string  "IWH05U",           :limit => 1
    t.string  "IG06",             :limit => 1
    t.string  "IAM06M",           :limit => 1
    t.string  "IAM06F",           :limit => 1
    t.string  "IAM06U",           :limit => 1
    t.string  "IAS06M",           :limit => 1
    t.string  "IAS06F",           :limit => 1
    t.string  "IAS06U",           :limit => 1
    t.string  "IHI06M",           :limit => 1
    t.string  "IHI06F",           :limit => 1
    t.string  "IHI06U",           :limit => 1
    t.string  "IBL06M",           :limit => 1
    t.string  "IBL06F",           :limit => 1
    t.string  "IBL06U",           :limit => 1
    t.string  "IWH06M",           :limit => 1
    t.string  "IWH06F",           :limit => 1
    t.string  "IWH06U",           :limit => 1
    t.string  "IG07",             :limit => 1
    t.string  "IAM07M",           :limit => 1
    t.string  "IAM07F",           :limit => 1
    t.string  "IAM07U",           :limit => 1
    t.string  "IAS07M",           :limit => 1
    t.string  "IAS07F",           :limit => 1
    t.string  "IAS07U",           :limit => 1
    t.string  "IHI07M",           :limit => 1
    t.string  "IHI07F",           :limit => 1
    t.string  "IHI07U",           :limit => 1
    t.string  "IBL07M",           :limit => 1
    t.string  "IBL07F",           :limit => 1
    t.string  "IBL07U",           :limit => 1
    t.string  "IWH07M",           :limit => 1
    t.string  "IWH07F",           :limit => 1
    t.string  "IWH07U",           :limit => 1
    t.string  "IG08",             :limit => 1
    t.string  "IAM08M",           :limit => 1
    t.string  "IAM08F",           :limit => 1
    t.string  "IAM08U",           :limit => 1
    t.string  "IAS08M",           :limit => 1
    t.string  "IAS08F",           :limit => 1
    t.string  "IAS08U",           :limit => 1
    t.string  "IHI08M",           :limit => 1
    t.string  "IHI08F",           :limit => 1
    t.string  "IHI08U",           :limit => 1
    t.string  "IBL08M",           :limit => 1
    t.string  "IBL08F",           :limit => 1
    t.string  "IBL08U",           :limit => 1
    t.string  "IWH08M",           :limit => 1
    t.string  "IWH08F",           :limit => 1
    t.string  "IWH08U",           :limit => 1
    t.string  "IG09",             :limit => 1
    t.string  "IAM09M",           :limit => 1
    t.string  "IAM09F",           :limit => 1
    t.string  "IAM09U",           :limit => 1
    t.string  "IAS09M",           :limit => 1
    t.string  "IAS09F",           :limit => 1
    t.string  "IAS09U",           :limit => 1
    t.string  "IHI09M",           :limit => 1
    t.string  "IHI09F",           :limit => 1
    t.string  "IHI09U",           :limit => 1
    t.string  "IBL09M",           :limit => 1
    t.string  "IBL09F",           :limit => 1
    t.string  "IBL09U",           :limit => 1
    t.string  "IWH09M",           :limit => 1
    t.string  "IWH09F",           :limit => 1
    t.string  "IWH09U",           :limit => 1
    t.string  "IG10",             :limit => 1
    t.string  "IAM10M",           :limit => 1
    t.string  "IAM10F",           :limit => 1
    t.string  "IAM10U",           :limit => 1
    t.string  "IAS10M",           :limit => 1
    t.string  "IAS10F",           :limit => 1
    t.string  "IAS10U",           :limit => 1
    t.string  "IHI10M",           :limit => 1
    t.string  "IHI10F",           :limit => 1
    t.string  "IHI10U",           :limit => 1
    t.string  "IBL10M",           :limit => 1
    t.string  "IBL10F",           :limit => 1
    t.string  "IBL10U",           :limit => 1
    t.string  "IWH10M",           :limit => 1
    t.string  "IWH10F",           :limit => 1
    t.string  "IWH10U",           :limit => 1
    t.string  "IG11",             :limit => 1
    t.string  "IAM11M",           :limit => 1
    t.string  "IAM11F",           :limit => 1
    t.string  "IAM11U",           :limit => 1
    t.string  "IAS11M",           :limit => 1
    t.string  "IAS11F",           :limit => 1
    t.string  "IAS11U",           :limit => 1
    t.string  "IHI11M",           :limit => 1
    t.string  "IHI11F",           :limit => 1
    t.string  "IHI11U",           :limit => 1
    t.string  "IBL11M",           :limit => 1
    t.string  "IBL11F",           :limit => 1
    t.string  "IBL11U",           :limit => 1
    t.string  "IWH11M",           :limit => 1
    t.string  "IWH11F",           :limit => 1
    t.string  "IWH11U",           :limit => 1
    t.string  "IG12",             :limit => 1
    t.string  "IAM12M",           :limit => 1
    t.string  "IAM12F",           :limit => 1
    t.string  "IAM12U",           :limit => 1
    t.string  "IAS12M",           :limit => 1
    t.string  "IAS12F",           :limit => 1
    t.string  "IAS12U",           :limit => 1
    t.string  "IHI12M",           :limit => 1
    t.string  "IHI12F",           :limit => 1
    t.string  "IHI12U",           :limit => 1
    t.string  "IBL12M",           :limit => 1
    t.string  "IBL12F",           :limit => 1
    t.string  "IBL12U",           :limit => 1
    t.string  "IWH12M",           :limit => 1
    t.string  "IWH12F",           :limit => 1
    t.string  "IWH12U",           :limit => 1
    t.string  "IUG",              :limit => 1
    t.string  "IAMUGM",           :limit => 1
    t.string  "IAMUGF",           :limit => 1
    t.string  "IAMUGU",           :limit => 1
    t.string  "IASUGM",           :limit => 1
    t.string  "IASUGF",           :limit => 1
    t.string  "IASUGU",           :limit => 1
    t.string  "IHIUGM",           :limit => 1
    t.string  "IHIUGF",           :limit => 1
    t.string  "IHIUGU",           :limit => 1
    t.string  "IBLUGM",           :limit => 1
    t.string  "IBLUGF",           :limit => 1
    t.string  "IBLUGU",           :limit => 1
    t.string  "IWHUGM",           :limit => 1
    t.string  "IWHUGF",           :limit => 1
    t.string  "IWHUGU",           :limit => 1
    t.string  "IMEMB",            :limit => 1
    t.string  "IAM",              :limit => 1
    t.string  "IAMALM",           :limit => 1
    t.string  "IAMALF",           :limit => 1
    t.string  "IAMALU",           :limit => 1
    t.string  "IASIAN",           :limit => 1
    t.string  "IASALM",           :limit => 1
    t.string  "IASALF",           :limit => 1
    t.string  "IASALU",           :limit => 1
    t.string  "IHISP",            :limit => 1
    t.string  "IHIALM",           :limit => 1
    t.string  "IHIALF",           :limit => 1
    t.string  "IHIALU",           :limit => 1
    t.string  "IBLACK",           :limit => 1
    t.string  "IBLALM",           :limit => 1
    t.string  "IBLALF",           :limit => 1
    t.string  "IBLALU",           :limit => 1
    t.string  "IWHITE",           :limit => 1
    t.string  "IWHALM",           :limit => 1
    t.string  "IWHALF",           :limit => 1
    t.string  "IWHALU",           :limit => 1
    t.string  "IETH",             :limit => 1
    t.string  "IPUTCH",           :limit => 1
    t.string  "ITOTGR",           :limit => 1
  end

  add_index "portal_nces06_schools", ["NCESSCH"], :name => "index_portal_nces06_schools_on_NCESSCH"
  add_index "portal_nces06_schools", ["SCHNAM"], :name => "index_portal_nces06_schools_on_SCHNAM"
  add_index "portal_nces06_schools", ["SEASCH"], :name => "index_portal_nces06_schools_on_SEASCH"
  add_index "portal_nces06_schools", ["STID"], :name => "index_portal_nces06_schools_on_STID"
  add_index "portal_nces06_schools", ["nces_district_id"], :name => "index_portal_nces06_schools_on_nces_district_id"

  create_table "portal_offerings", :force => true do |t|
    t.string   "uuid",             :limit => 36
    t.string   "status"
    t.integer  "clazz_id"
    t.integer  "runnable_id"
    t.string   "runnable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                         :default => true
    t.boolean  "default_offering",               :default => false
  end

  create_table "portal_school_memberships", :force => true do |t|
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "member_id"
    t.string   "member_type"
    t.integer  "school_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portal_school_memberships", ["member_type", "member_id"], :name => "member_type_id_index"

  create_table "portal_schools", :force => true do |t|
    t.string   "uuid",           :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "district_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nces_school_id"
    t.string   "state",          :limit => 2
    t.string   "zipcode",        :limit => 5
    t.string   "ncessch",        :limit => 12
  end

  add_index "portal_schools", ["state"], :name => "index_portal_schools_on_state"

  create_table "portal_semesters", :force => true do |t|
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "school_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portal_student_clazzes", :force => true do |t|
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "clazz_id"
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portal_student_clazzes", ["clazz_id"], :name => "index_portal_student_clazzes_on_clazz_id"
  add_index "portal_student_clazzes", ["student_id", "clazz_id"], :name => "student_class_index"

  create_table "portal_students", :force => true do |t|
    t.string   "uuid",           :limit => 36
    t.integer  "user_id"
    t.integer  "grade_level_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portal_students", ["user_id"], :name => "index_portal_students_on_user_id"

  create_table "portal_subjects", :force => true do |t|
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portal_teacher_clazzes", :force => true do |t|
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "clazz_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portal_teacher_clazzes", ["clazz_id"], :name => "index_portal_teacher_clazzes_on_clazz_id"
  add_index "portal_teacher_clazzes", ["teacher_id"], :name => "index_portal_teacher_clazzes_on_teacher_id"

  create_table "portal_teachers", :force => true do |t|
    t.string   "uuid",            :limit => 36
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domain_id"
    t.integer  "offerings_count",               :default => 0
  end

  add_index "portal_teachers", ["user_id"], :name => "index_portal_teachers_on_user_id"

  create_table "probe_calibrations", :force => true do |t|
    t.integer  "data_filter_id"
    t.integer  "probe_type_id"
    t.boolean  "default_calibration"
    t.integer  "physical_unit_id"
    t.string   "name"
    t.text     "description"
    t.float    "k0"
    t.float    "k1"
    t.float    "k2"
    t.float    "k3"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "probe_data_filters", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.string   "otrunk_object_class"
    t.boolean  "k0_active"
    t.boolean  "k1_active"
    t.boolean  "k2_active"
    t.boolean  "k3_active"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "probe_device_configs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "vendor_interface_id"
    t.string   "config_string"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "probe_physical_units", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "quantity"
    t.string   "unit_symbol"
    t.string   "unit_symbol_text"
    t.text     "description"
    t.boolean  "si"
    t.boolean  "base_unit"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "probe_probe_types", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "ptype"
    t.float    "step_size"
    t.integer  "display_precision"
    t.integer  "port"
    t.string   "unit"
    t.float    "min"
    t.float    "max"
    t.float    "period"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "probe_vendor_interfaces", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "short_name"
    t.text     "description"
    t.string   "communication_protocol"
    t.string   "image"
    t.string   "uuid"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "driver_short_name"
  end

  create_table "properties_versioned_jnlps", :id => false, :force => true do |t|
    t.integer "property_id"
    t.integer "versioned_jnlp_id"
  end

  create_table "report_embeddable_filters", :force => true do |t|
    t.integer  "offering_id"
    t.text     "embeddables"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ignore"
  end

  create_table "resource_pages", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.string   "publication_status", :default => "draft"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offerings_count",    :default => 0
    t.text     "content"
  end

  create_table "ri_gse_assessment_target_unifying_themes", :id => false, :force => true do |t|
    t.integer "assessment_target_id"
    t.integer "unifying_theme_id"
  end

  create_table "ri_gse_assessment_targets", :force => true do |t|
    t.integer  "knowledge_statement_id"
    t.integer  "number"
    t.text     "description"
    t.string   "grade_span"
    t.string   "uuid",                   :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ri_gse_big_ideas", :force => true do |t|
    t.integer  "unifying_theme_id"
    t.text     "description"
    t.string   "uuid",              :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ri_gse_domains", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.string   "uuid",       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ri_gse_expectation_indicators", :force => true do |t|
    t.integer  "expectation_id"
    t.text     "description"
    t.string   "ordinal"
    t.string   "uuid",           :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ri_gse_expectation_stems", :force => true do |t|
    t.text     "description"
    t.string   "uuid",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ri_gse_expectations", :force => true do |t|
    t.integer  "expectation_stem_id"
    t.string   "uuid",                      :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grade_span_expectation_id"
  end

  create_table "ri_gse_grade_span_expectations", :force => true do |t|
    t.integer  "assessment_target_id"
    t.string   "grade_span"
    t.string   "uuid",                 :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gse_key"
  end

  create_table "ri_gse_knowledge_statements", :force => true do |t|
    t.integer  "domain_id"
    t.integer  "number"
    t.text     "description"
    t.string   "uuid",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ri_gse_unifying_themes", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.string   "uuid",       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string  "title"
    t.integer "position"
    t.string  "uuid",     :limit => 36
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id"
  add_index "roles_users", ["user_id", "role_id"], :name => "index_roles_users_on_user_id_and_role_id"

  create_table "saveable_image_question_answers", :force => true do |t|
    t.integer  "image_question_id"
    t.integer  "bundle_content_id"
    t.integer  "blob_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saveable_image_question_answers", ["image_question_id", "position"], :name => "i_q_id_and_position_index"

  create_table "saveable_image_questions", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "offering_id"
    t.integer  "image_question_id"
    t.integer  "response_count",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saveable_image_questions", ["learner_id"], :name => "index_saveable_image_questions_on_learner_id"
  add_index "saveable_image_questions", ["offering_id"], :name => "index_saveable_image_questions_on_offering_id"

  create_table "saveable_multiple_choice_answers", :force => true do |t|
    t.integer  "multiple_choice_id"
    t.integer  "bundle_content_id"
    t.integer  "choice_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saveable_multiple_choice_answers", ["multiple_choice_id", "position"], :name => "m_c_id_and_position_index"

  create_table "saveable_multiple_choices", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "multiple_choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offering_id"
    t.integer  "response_count",     :default => 0
  end

  add_index "saveable_multiple_choices", ["learner_id"], :name => "index_saveable_multiple_choices_on_learner_id"
  add_index "saveable_multiple_choices", ["offering_id"], :name => "index_saveable_multiple_choices_on_offering_id"

  create_table "saveable_open_response_answers", :force => true do |t|
    t.integer  "open_response_id"
    t.integer  "bundle_content_id"
    t.integer  "position"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saveable_open_response_answers", ["open_response_id", "position"], :name => "o_r_id_and_position_index"

  create_table "saveable_open_responses", :force => true do |t|
    t.integer  "learner_id"
    t.integer  "open_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offering_id"
    t.integer  "response_count",   :default => 0
  end

  add_index "saveable_open_responses", ["learner_id"], :name => "index_saveable_open_responses_on_learner_id"
  add_index "saveable_open_responses", ["offering_id"], :name => "index_saveable_open_responses_on_offering_id"

  create_table "saveable_sparks_measuring_resistance", :force => true do |t|
    t.integer  "learner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offering_id"
  end

  add_index "saveable_sparks_measuring_resistance", ["learner_id"], :name => "index_saveable_sparks_measuring_resistance_on_learner_id"
  add_index "saveable_sparks_measuring_resistance", ["offering_id"], :name => "index_saveable_sparks_measuring_resistance_on_offering_id"

  create_table "saveable_sparks_measuring_resistance_reports", :force => true do |t|
    t.integer  "measuring_resistance_id"
    t.integer  "position"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.string   "uuid",               :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "teacher_only",                     :default => false
    t.string   "publication_status"
  end

  add_index "sections", ["activity_id", "position"], :name => "index_sections_on_activity_id_and_position"
  add_index "sections", ["position"], :name => "index_sections_on_position"

  create_table "security_questions", :force => true do |t|
    t.integer "user_id",                 :null => false
    t.string  "question", :limit => 100, :null => false
    t.string  "answer",   :limit => 100, :null => false
  end

  add_index "security_questions", ["user_id"], :name => "index_security_questions_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.integer  "scope_id"
    t.string   "scope_type"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name"
  add_index "settings", ["scope_id", "scope_type", "name"], :name => "index_settings_on_scope_id_and_scope_type_and_name"
  add_index "settings", ["scope_type", "scope_id", "name"], :name => "index_settings_on_scope_type_and_scope_id_and_name"
  add_index "settings", ["value"], :name => "index_settings_on_value"

  create_table "student_views", :force => true do |t|
    t.integer "user_id",       :null => false
    t.integer "viewable_id",   :null => false
    t.string  "viewable_type", :null => false
    t.integer "count"
  end

  add_index "student_views", ["user_id", "viewable_id", "viewable_type"], :name => "index_student_views_on_user_id_and_viewable_id_and_viewable_type"

  create_table "teacher_notes", :force => true do |t|
    t.text     "body"
    t.string   "uuid",                 :limit => 36
    t.integer  "authored_entity_id"
    t.string   "authored_entity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "first_name",                :limit => 100, :default => ""
    t.string   "last_name",                 :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.string   "activation_code",           :limit => 40
    t.string   "state",                                    :default => "passive", :null => false
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.string   "uuid",                      :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vendor_interface_id"
    t.boolean  "default_user",                             :default => false
    t.boolean  "site_admin",                               :default => false
    t.string   "type"
    t.integer  "external_user_domain_id"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
