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

ActiveRecord::Schema.define(:version => 20090619194701) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "uuid",             :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "is_template"
    t.integer  "position"
    t.integer  "investigation_id"
    t.integer  "original_id"
    t.boolean  "teacher_only",                   :default => false
  end

  create_table "assessment_targets", :force => true do |t|
    t.integer  "knowledge_statement_id"
    t.integer  "unifying_theme_id"
    t.integer  "number"
    t.string   "description"
    t.string   "grade_span"
    t.string   "uuid",                   :limit => 36
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

  create_table "big_ideas", :force => true do |t|
    t.integer  "unifying_theme_id"
    t.string   "description"
    t.string   "uuid",              :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biologica_organisms", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                  :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "sex"
    t.string   "alleles"
    t.string   "strain"
    t.integer  "chromosomes_color"
    t.boolean  "fatal_characteristics"
    t.integer  "biologica_world_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biologica_organisms_biologica_pedigrees", :id => false, :force => true do |t|
    t.integer  "biologica_pedigree_id"
    t.integer  "biologica_organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biologica_pedigrees", :force => true do |t|
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

  create_table "biologica_static_organisms", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                  :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "biologica_organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biologica_worlds", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",         :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "species_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "calibrations", :force => true do |t|
    t.integer "data_filter_id"
    t.integer "probe_type_id"
    t.boolean "default_calibration"
    t.integer "physical_unit_id"
    t.string  "name"
    t.text    "description"
    t.float   "k0"
    t.float   "k1"
    t.float   "k2"
    t.float   "k3"
    t.string  "uuid"
  end

  create_table "data_collectors", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.string   "uuid",                       :limit => 36
    t.integer  "y_axis_min",                               :default => 0
    t.integer  "y_axis_max",                               :default => 5
    t.integer  "x_axis_min",                               :default => 0
    t.integer  "x_axis_max",                               :default => 60
    t.string   "title"
    t.string   "x_axis_label"
    t.string   "x_axis_units"
    t.string   "y_axis_label"
    t.string   "y_axis_units"
    t.boolean  "multiple_graphable_enabled"
    t.boolean  "draw_marks"
    t.boolean  "connect_points"
    t.boolean  "autoscale_enabled"
    t.boolean  "ruler_enabled"
    t.boolean  "show_tare"
    t.boolean  "single_value"
    t.integer  "probe_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "graph_type_id"
    t.integer  "prediction_graph_id"
    t.text     "otml_root_content"
    t.text     "otml_library_content"
    t.text     "data_store_values"
  end

  create_table "data_filters", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.text    "description"
    t.string  "otrunk_object_class"
    t.boolean "k0_active"
    t.boolean "k1_active"
    t.boolean "k2_active"
    t.boolean "k3_active"
    t.string  "uuid"
  end

  create_table "data_tables", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",         :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "column_count"
    t.integer  "visible_rows"
    t.text     "column_names"
    t.text     "column_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_configs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "vendor_interface_id"
    t.string   "config_string"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.string   "uuid",       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drawing_tools", :force => true do |t|
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

  create_table "expectation_indicators", :force => true do |t|
    t.integer  "expectation_id"
    t.string   "description"
    t.string   "ordinal"
    t.string   "uuid",           :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expectation_stems", :force => true do |t|
    t.string   "description"
    t.string   "uuid",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expectations", :force => true do |t|
    t.integer  "expectation_stem_id"
    t.string   "uuid",                      :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "grade_span_expectation_id"
  end

  create_table "grade_span_expectations", :force => true do |t|
    t.integer  "assessment_target_id"
    t.string   "grade_span"
    t.string   "uuid",                 :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gse_key"
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
  end

  create_table "jars_versioned_jnlps", :id => false, :force => true do |t|
    t.integer "jar_id"
    t.integer "versioned_jnlp_id"
  end

  create_table "knowledge_statements", :force => true do |t|
    t.integer  "domain_id"
    t.integer  "number"
    t.string   "description"
    t.string   "uuid",        :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "uuid"
    t.integer  "maven_jnlp_family_id"
    t.string   "path"
    t.string   "url"
    t.string   "version_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "multiple_choice_choices", :force => true do |t|
    t.text     "choice"
    t.integer  "multiple_choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_correct"
  end

  create_table "multiple_choices", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "prompt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mw_modeler_pages", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",              :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "authored_data_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "n_logo_models", :force => true do |t|
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

  create_table "native_libraries_versioned_jnlps", :id => false, :force => true do |t|
    t.integer "native_library_id"
    t.integer "versioned_jnlp_id"
  end

  create_table "open_responses", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.string   "uuid",             :limit => 36
    t.text     "prompt"
    t.string   "default_response"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_id"
    t.integer  "position"
    t.integer  "embeddable_id"
    t.string   "embeddable_type"
  end

  add_index "page_elements", ["embeddable_id"], :name => "index_page_elements_on_embeddable_id"
  add_index "page_elements", ["page_id"], :name => "index_page_elements_on_page_id"
  add_index "page_elements", ["position"], :name => "index_page_elements_on_position"

  create_table "pages", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "position"
    t.integer  "section_id"
    t.string   "uuid",         :limit => 36
    t.boolean  "teacher_only",               :default => false
  end

  add_index "pages", ["position"], :name => "index_pages_on_position"

  create_table "passwords", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_code"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physical_units", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.string  "quantity"
    t.string  "unit_symbol"
    t.string  "unit_symbol_text"
    t.text    "description"
    t.boolean "si"
    t.boolean "base_unit"
    t.string  "uuid"
  end

  create_table "probe_types", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.integer "ptype"
    t.float   "step_size"
    t.integer "display_precision"
    t.integer "port"
    t.string  "unit"
    t.float   "min"
    t.float   "max"
    t.float   "period"
    t.string  "uuid"
  end

  create_table "properties_versioned_jnlps", :id => false, :force => true do |t|
    t.integer "property_id"
    t.integer "versioned_jnlp_id"
  end

  create_table "raw_otmls", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "content"
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

  create_table "sections", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "position"
    t.integer  "activity_id"
    t.string   "uuid",         :limit => 36
    t.boolean  "teacher_only",               :default => false
  end

  add_index "sections", ["position"], :name => "index_sections_on_position"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "teacher_notes", :force => true do |t|
    t.text     "body"
    t.string   "uuid",                 :limit => 36
    t.integer  "authored_entity_id"
    t.string   "authored_entity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "unifying_themes", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.string   "uuid",       :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "identity_url"
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
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "vendor_interfaces", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.string  "short_name"
    t.text    "description"
    t.string  "communication_protocol"
    t.string  "image"
    t.string  "uuid"
    t.integer "device_id"
  end

  create_table "xhtmls", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "user_id"
    t.string  "uuid",        :limit => 36
    t.text    "content"
  end

end
