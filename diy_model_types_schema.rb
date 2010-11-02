# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define() do

  create_table "itsidiy_activities", :force => true do |t|
    t.integer "user_id"
    t.string  "uuid"
    t.boolean "public"
    t.boolean "draft"
    t.string  "short_name"
    t.boolean "textile"
    t.string  "name"
    t.string  "description"
    t.text    "introduction"
    t.text    "standards"
    t.integer "probe_type_id"
    t.text    "materials"
    t.text    "safety"
    t.text    "proced"
    t.text    "predict"
    t.text    "collectdata"
    t.text    "analysis"
    t.text    "conclusion"
    t.text    "further"
    t.integer "sds_offering_id"
    t.string  "content_digest"
    t.boolean "introduction_text_response"
    t.boolean "prediction_text_response"
    t.boolean "prediction_graph_response"
    t.boolean "proced_text_response"
    t.boolean "proced_drawing_response"
    t.boolean "collectdata_text_response"
    t.boolean "analysis_text_response"
    t.boolean "conclusion_text_response"
    t.boolean "further_text_response"
    t.text    "collectdata2"
    t.boolean "collectdata2_text_response"
    t.boolean "collectdata_probe_active"
    t.boolean "collectdata_model_active"
    t.boolean "collectdata2_probe_active"
    t.boolean "collectdata2_model_active"
    t.integer "collectdata2_probetype_id"
    t.integer "model_id"
    t.integer "collectdata2_model_id"
    t.boolean "collectdata_probe_multi"
    t.boolean "collectdata2_probe_multi"
    t.text    "collectdata3"
    t.boolean "collectdata3_text_response"
    t.boolean "collectdata3_probe_active"
    t.boolean "collectdata3_model_active"
    t.boolean "collectdata3_probe_multi"
    t.integer "collectdata3_probetype_id"
    t.integer "collectdata3_model_id"
    t.boolean "further_model_active"
    t.integer "further_model_id"
    t.boolean "collectdata_drawing_response"
    t.boolean "collectdata2_drawing_response"
    t.boolean "collectdata3_drawing_response"
    t.boolean "further_drawing_response"
    t.boolean "introduction_drawing_response"
    t.boolean "prediction_drawing_response"
    t.boolean "analysis_drawing_response"
    t.boolean "conclusion_drawing_response"
    t.boolean "further_probe_active"
    t.integer "further_probetype_id"
    t.boolean "further_probe_multi"
    t.text    "custom_otml"
    t.boolean "collectdata_graph_response"
    t.boolean "collectdata1_calibration_active"
    t.integer "collectdata1_calibration_id"
    t.boolean "collectdata2_calibration_active"
    t.integer "collectdata2_calibration_id"
    t.boolean "collectdata3_calibration_active"
    t.integer "collectdata3_calibration_id"
    t.boolean "furtherprobe_calibration_active"
    t.integer "furtherprobe_calibration_id"
    t.boolean "nobundles"
    t.integer "parent_id"
    t.integer "parent_version"
    t.integer "version"
    t.integer "previous_user_id"
    t.string  "image_url"
    t.text    "career_stem"
    t.boolean "career_stem_text_response"
    t.boolean "archived",                        :default => false
    t.text    "career_stem2"
    t.boolean "career_stem2_text_response"
  end

  add_index "itsidiy_activities", ["user_id"], :name => "index_itsidiy_activities_on_user_id"
  add_index "itsidiy_activities", ["public"], :name => "index_itsidiy_activities_on_public"
  add_index "itsidiy_activities", ["id"], :name => "index_itsidiy_activities_on_id"
  add_index "itsidiy_activities", ["name"], :name => "index_itsidiy_activities_on_name"
  add_index "itsidiy_activities", ["model_id"], :name => "index_itsidiy_activities_on_model_id"

  create_table "itsidiy_activities_versions", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "version"
    t.integer  "user_id"
    t.string   "uuid"
    t.boolean  "public"
    t.boolean  "draft"
    t.string   "short_name"
    t.boolean  "textile"
    t.string   "name"
    t.string   "description"
    t.text     "introduction"
    t.text     "standards"
    t.integer  "probe_type_id"
    t.text     "materials"
    t.text     "safety"
    t.text     "proced"
    t.text     "predict"
    t.text     "collectdata"
    t.text     "analysis"
    t.text     "conclusion"
    t.text     "further"
    t.integer  "sds_offering_id"
    t.string   "content_digest"
    t.boolean  "introduction_text_response"
    t.boolean  "prediction_text_response"
    t.boolean  "prediction_graph_response"
    t.boolean  "proced_text_response"
    t.boolean  "proced_drawing_response"
    t.boolean  "collectdata_text_response"
    t.boolean  "analysis_text_response"
    t.boolean  "conclusion_text_response"
    t.boolean  "further_text_response"
    t.text     "collectdata2"
    t.boolean  "collectdata2_text_response"
    t.boolean  "collectdata_probe_active"
    t.boolean  "collectdata_model_active"
    t.boolean  "collectdata2_probe_active"
    t.boolean  "collectdata2_model_active"
    t.integer  "collectdata2_probetype_id"
    t.integer  "model_id"
    t.integer  "collectdata2_model_id"
    t.boolean  "collectdata_probe_multi"
    t.boolean  "collectdata2_probe_multi"
    t.text     "collectdata3"
    t.boolean  "collectdata3_text_response"
    t.boolean  "collectdata3_probe_active"
    t.boolean  "collectdata3_model_active"
    t.boolean  "collectdata3_probe_multi"
    t.integer  "collectdata3_probetype_id"
    t.integer  "collectdata3_model_id"
    t.boolean  "further_model_active"
    t.integer  "further_model_id"
    t.boolean  "collectdata_drawing_response"
    t.boolean  "collectdata2_drawing_response"
    t.boolean  "collectdata3_drawing_response"
    t.boolean  "further_drawing_response"
    t.boolean  "introduction_drawing_response"
    t.boolean  "prediction_drawing_response"
    t.boolean  "analysis_drawing_response"
    t.boolean  "conclusion_drawing_response"
    t.boolean  "further_probe_active"
    t.integer  "further_probetype_id"
    t.boolean  "further_probe_multi"
    t.text     "custom_otml"
    t.boolean  "collectdata_graph_response"
    t.boolean  "collectdata1_calibration_active"
    t.integer  "collectdata1_calibration_id"
    t.boolean  "collectdata2_calibration_active"
    t.integer  "collectdata2_calibration_id"
    t.boolean  "collectdata3_calibration_active"
    t.integer  "collectdata3_calibration_id"
    t.boolean  "furtherprobe_calibration_active"
    t.integer  "furtherprobe_calibration_id"
    t.boolean  "nobundles"
    t.integer  "parent_id"
    t.integer  "parent_version"
    t.datetime "updated_at"
    t.integer  "previous_user_id"
    t.text     "career_stem"
    t.boolean  "career_stem_text_response"
    t.boolean  "archived",                        :default => false
    t.text     "career_stem2"
    t.boolean  "career_stem2_text_response"
  end

  create_table "itsidiy_calibrations", :force => true do |t|
    t.integer "data_filter_id"
    t.integer "probe_type_id"
    t.boolean "default_calibration"
    t.integer "physical_unit_id"
    t.integer "user_id"
    t.string  "name"
    t.text    "description"
    t.float   "k0"
    t.float   "k1"
    t.float   "k2"
    t.float   "k3"
    t.integer "y_axis_min"
    t.integer "y_axis_max"
    t.integer "x_axis_min"
    t.integer "x_axis_max"
    t.integer "previous_user_id"
    t.string  "uuid"
  end

  create_table "itsidiy_data_filters", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.text    "description"
    t.string  "otrunk_object_class"
    t.boolean "k0_active"
    t.boolean "k1_active"
    t.boolean "k2_active"
    t.boolean "k3_active"
    t.integer "previous_user_id"
    t.string  "uuid"
  end

  create_table "itsidiy_device_configs", :force => true do |t|
    t.integer  "vendor_interface_id"
    t.string   "config_string"
    t.integer  "user_id"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "previous_user_id"
  end

  create_table "itsidiy_external_otrunk_activities", :force => true do |t|
    t.integer "user_id"
    t.boolean "public"
    t.string  "name"
    t.text    "description"
    t.text    "otml"
    t.integer "sds_offering_id"
    t.string  "short_name"
    t.string  "uuid"
    t.string  "external_otml_url"
    t.boolean "external_otml_always_update"
    t.date    "external_otml_last_modified"
    t.string  "external_otml_filename"
    t.string  "custom_reporting_mode"
    t.boolean "nobundles"
    t.integer "parent_id"
    t.integer "parent_version"
    t.integer "version"
    t.integer "previous_user_id"
  end

  add_index "itsidiy_external_otrunk_activities", ["user_id"], :name => "index_itsidiy_external_otrunk_activities_on_user_id"
  add_index "itsidiy_external_otrunk_activities", ["public"], :name => "index_itsidiy_external_otrunk_activities_on_public"

  create_table "itsidiy_external_otrunk_activities_versions", :force => true do |t|
    t.integer  "external_otrunk_activity_id"
    t.integer  "version"
    t.integer  "user_id"
    t.boolean  "public"
    t.string   "name"
    t.text     "description"
    t.text     "otml"
    t.integer  "sds_offering_id"
    t.string   "short_name"
    t.string   "uuid"
    t.string   "external_otml_url"
    t.boolean  "external_otml_always_update"
    t.date     "external_otml_last_modified"
    t.string   "external_otml_filename"
    t.string   "custom_reporting_mode"
    t.boolean  "nobundles"
    t.integer  "parent_id"
    t.integer  "parent_version"
    t.datetime "updated_at"
    t.integer  "previous_user_id"
  end

  create_table "itsidiy_groups", :force => true do |t|
    t.boolean "public"
    t.string  "key"
    t.boolean "textile"
    t.string  "name"
    t.string  "description"
    t.text    "introduction"
    t.string  "uuid"
  end

  create_table "itsidiy_learner_sessions", :force => true do |t|
    t.integer  "learner_id"
    t.datetime "created_at"
    t.string   "uuid"
  end

  add_index "itsidiy_learner_sessions", ["learner_id"], :name => "index_itsidiy_learner_sessions_on_learner_id"
  add_index "itsidiy_learner_sessions", ["created_at"], :name => "index_itsidiy_learner_sessions_on_created_at"

  create_table "itsidiy_learners", :force => true do |t|
    t.integer "user_id"
    t.integer "runnable_id"
    t.integer "sds_workgroup_id"
    t.string  "runnable_type"
    t.integer "previous_user_id"
    t.string  "uuid"
  end

  add_index "itsidiy_learners", ["runnable_id"], :name => "index_itsidiy_learners_on_runnable_id"
  add_index "itsidiy_learners", ["runnable_type"], :name => "index_itsidiy_learners_on_runnable_type"

  create_table "itsidiy_levelings", :force => true do |t|
    t.integer "level_id"
    t.integer "levelable_id"
    t.string  "levelable_type"
    t.string  "uuid"
  end

  create_table "itsidiy_levels", :force => true do |t|
    t.string "name"
    t.text   "description"
    t.date   "created_on"
    t.date   "updated_on"
    t.string "uuid"
  end

  create_table "itsidiy_memberships", :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.integer "role_id"
    t.integer "previous_user_id"
    t.string  "uuid"
  end

  create_table "itsidiy_model_types", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.string  "url"
    t.text    "credits"
    t.string  "otrunk_object_class"
    t.string  "otrunk_view_class"
    t.boolean "authorable"
    t.integer "user_id"
    t.boolean "sizeable"
    t.integer "previous_user_id"
    t.string  "uuid"
  end

  add_index "itsidiy_model_types", ["user_id"], :name => "index_itsidiy_model_types_on_user_id"

  create_table "itsidiy_models", :force => true do |t|
    t.integer "user_id"
    t.integer "model_type_id"
    t.string  "name"
    t.string  "url"
    t.boolean "public"
    t.boolean "textile"
    t.text    "description"
    t.text    "instructions"
    t.boolean "snapshot_active"
    t.text    "credits"
    t.string  "uuid"
    t.integer "sds_offering_id"
    t.string  "short_name"
    t.integer "height"
    t.integer "width"
    t.boolean "nobundles"
    t.integer "parent_id"
    t.integer "parent_version"
    t.integer "version"
    t.integer "previous_user_id"
    t.string  "image_url"
  end

  add_index "itsidiy_models", ["user_id"], :name => "index_itsidiy_models_on_user_id"
  add_index "itsidiy_models", ["public"], :name => "index_itsidiy_models_on_public"
  add_index "itsidiy_models", ["model_type_id"], :name => "index_itsidiy_models_on_model_type_id"

  create_table "itsidiy_models_versions", :force => true do |t|
    t.integer  "model_id"
    t.integer  "version"
    t.integer  "user_id"
    t.integer  "model_type_id"
    t.string   "name"
    t.string   "url"
    t.boolean  "public"
    t.boolean  "textile"
    t.text     "description"
    t.text     "instructions"
    t.boolean  "snapshot_active"
    t.text     "credits"
    t.string   "uuid"
    t.integer  "sds_offering_id"
    t.string   "short_name"
    t.integer  "height"
    t.integer  "width"
    t.boolean  "nobundles"
    t.integer  "parent_id"
    t.integer  "parent_version"
    t.datetime "updated_at"
    t.integer  "previous_user_id"
  end

  create_table "itsidiy_otrunk_report_templates", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.boolean  "public"
    t.string   "name"
    t.text     "description"
    t.text     "otml"
    t.integer  "sds_offering_id"
    t.string   "short_name"
    t.string   "uuid"
    t.string   "external_otml_url"
    t.boolean  "external_otml_always_update"
    t.datetime "external_otml_last_modified"
    t.string   "external_otml_filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "previous_user_id"
  end

  create_table "itsidiy_otrunk_report_templates_versions", :force => true do |t|
    t.integer  "otrunk_report_template_id"
    t.integer  "version"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.boolean  "public"
    t.string   "name"
    t.text     "description"
    t.text     "otml"
    t.integer  "sds_offering_id"
    t.string   "short_name"
    t.string   "uuid"
    t.string   "external_otml_url"
    t.boolean  "external_otml_always_update"
    t.datetime "external_otml_last_modified"
    t.string   "external_otml_filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "previous_user_id"
  end

  create_table "itsidiy_physical_units", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.string  "quantity"
    t.string  "unit_symbol"
    t.string  "unit_symbol_text"
    t.text    "description"
    t.boolean "si"
    t.boolean "base_unit"
    t.integer "previous_user_id"
    t.string  "uuid"
  end

  create_table "itsidiy_probe_types", :force => true do |t|
    t.string  "name"
    t.integer "ptype"
    t.float   "step_size"
    t.integer "display_precision"
    t.integer "port"
    t.string  "unit"
    t.float   "min"
    t.float   "max"
    t.float   "period"
    t.integer "user_id"
    t.integer "previous_user_id"
    t.string  "uuid"
  end

  add_index "itsidiy_probe_types", ["name"], :name => "index_itsidiy_probe_types_on_name"

  create_table "itsidiy_probes", :force => true do |t|
    t.integer "user_id"
    t.integer "probe_type_id"
    t.integer "vendor_interface_id"
    t.string  "name"
    t.string  "model_number"
    t.binary  "image"
    t.integer "previous_user_id"
    t.string  "uuid"
  end

  create_table "itsidiy_report_types", :force => true do |t|
    t.string   "uuid"
    t.string   "uri"
    t.string   "name"
    t.boolean  "limit_to_one",     :default => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "previous_user_id"
  end

  add_index "itsidiy_report_types", ["uri"], :name => "index_itsidiy_report_types_on_uri"
  add_index "itsidiy_report_types", ["name"], :name => "index_itsidiy_report_types_on_name"
  add_index "itsidiy_report_types", ["user_id"], :name => "index_itsidiy_report_types_on_user_id"

  create_table "itsidiy_report_types_reports", :id => false, :force => true do |t|
    t.integer "report_type_id"
    t.integer "report_id"
  end

  add_index "itsidiy_report_types_reports", ["report_type_id"], :name => "index_itsidiy_report_types_reports_on_report_type_id"
  add_index "itsidiy_report_types_reports", ["report_id"], :name => "index_itsidiy_report_types_reports_on_report_id"

  create_table "itsidiy_reports", :force => true do |t|
    t.integer  "otrunk_report_template_id"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "previous_user_id"
    t.boolean  "public"
    t.integer  "custom_offering_id"
    t.integer  "custom_workgroup_id"
  end

  create_table "itsidiy_roles", :force => true do |t|
    t.string  "title"
    t.integer "position"
    t.string  "uuid"
  end

  add_index "itsidiy_roles", ["id"], :name => "index_itsidiy_roles_on_id"

  create_table "itsidiy_roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "itsidiy_roles_users", ["role_id"], :name => "index_itsidiy_roles_users_on_role_id"
  add_index "itsidiy_roles_users", ["user_id"], :name => "index_itsidiy_roles_users_on_user_id"

  create_table "itsidiy_schema_info", :id => false, :force => true do |t|
    t.integer "version"
  end

  create_table "itsidiy_sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "itsidiy_sessions", ["session_id"], :name => "index_itsidiy_sessions_on_session_id"

  create_table "itsidiy_subjectings", :force => true do |t|
    t.integer "subject_id"
    t.integer "subjectable_id"
    t.string  "subjectable_type"
    t.string  "uuid"
  end

  create_table "itsidiy_subjects", :force => true do |t|
    t.string "name"
    t.text   "description"
    t.date   "created_on"
    t.date   "updated_on"
    t.string "uuid"
  end

  create_table "itsidiy_unit_activities", :force => true do |t|
    t.integer "activity_id"
    t.integer "unit_id"
    t.integer "position"
    t.string  "uuid"
  end

  create_table "itsidiy_units", :force => true do |t|
    t.string "name"
    t.text   "description"
    t.text   "notes"
    t.date   "created_on"
    t.date   "updated_on"
    t.string "uuid"
  end

  create_table "itsidiy_users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "vendor_interface_id"
    t.string   "password_hash"
    t.integer  "sds_sail_user_id"
    t.boolean  "disable_javascript"
    t.string   "uuid"
  end

  create_table "itsidiy_vendor_interfaces", :force => true do |t|
    t.string  "name"
    t.string  "short_name"
    t.text    "description"
    t.string  "communication_protocol"
    t.string  "image"
    t.integer "user_id"
    t.integer "previous_user_id"
    t.string  "uuid"
    t.integer "device_id"
  end

  add_index "itsidiy_vendor_interfaces", ["id"], :name => "index_itsidiy_vendor_interfaces_on_id"

  create_table "itsisu_diyactivities", :force => true do |t|
    t.integer "user_id"
    t.string  "uuid"
    t.boolean "public"
    t.boolean "draft"
    t.string  "short_name"
    t.boolean "textile"
    t.string  "name"
    t.string  "description"
    t.text    "introduction"
    t.text    "standards"
    t.integer "probe_type_id"
    t.text    "materials"
    t.text    "safety"
    t.text    "proced"
    t.text    "predict"
    t.text    "collectdata"
    t.text    "analysis"
    t.text    "conclusion"
    t.text    "further"
    t.integer "sds_offering_id"
    t.string  "content_digest"
    t.boolean "introduction_text_response"
    t.boolean "prediction_text_response"
    t.boolean "prediction_graph_response"
    t.boolean "proced_text_response"
    t.boolean "proced_drawing_response"
    t.boolean "collectdata_text_response"
    t.boolean "analysis_text_response"
    t.boolean "conclusion_text_response"
    t.boolean "further_text_response"
    t.text    "collectdata2"
    t.boolean "collectdata2_text_response"
    t.boolean "collectdata_probe_active"
    t.boolean "collectdata_model_active"
    t.boolean "collectdata2_probe_active"
    t.boolean "collectdata2_model_active"
    t.integer "collectdata2_probetype_id"
    t.integer "model_id"
    t.integer "collectdata2_model_id"
  end

  create_table "itsisu_diyactivity_sessions", :force => true do |t|
    t.integer  "learner_id"
    t.datetime "created_at"
    t.integer  "activity_id"
  end

  create_table "itsisu_diyusers", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "vendor_interface_id"
    t.string   "password_hash"
    t.integer  "sds_sail_user_id"
  end

  create_table "itsisu_diyvendor_interfaces", :force => true do |t|
    t.string "name"
    t.string "short_name"
    t.text   "description"
    t.string "communication_protocol"
    t.string "image"
  end

end
