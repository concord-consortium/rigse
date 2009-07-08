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

ActiveRecord::Schema.define(:version => 20090701205051) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",             :limit => 36
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_template"
    t.integer  "position"
    t.integer  "investigation_id"
    t.integer  "original_id"
    t.boolean  "teacher_only",                   :default => false
  end

  create_table "assessment_target_unifying_themes", :id => false, :force => true do |t|
    t.integer "assessment_target_id"
    t.integer "unifying_theme_id"
  end

  create_table "assessment_targets", :force => true do |t|
    t.integer  "knowledge_statement_id"
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

  create_table "biologica_breed_offsprings", :force => true do |t|
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

  create_table "biologica_chromosome_zooms", :force => true do |t|
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

  create_table "biologica_chromosome_zooms_biologica_organisms", :id => false, :force => true do |t|
    t.integer  "biologica_chromosome_zoom_id"
    t.integer  "biologica_organism_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biologica_chromosomes", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",                  :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "biologica_organism_id"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "biologica_meiosis_views", :force => true do |t|
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

  create_table "biologica_multiple_organisms", :force => true do |t|
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

  create_table "biologica_multiple_organisms_biologica_organisms", :id => false, :force => true do |t|
    t.integer  "biologica_multiple_organism_id"
    t.integer  "biologica_organism_id"
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
  end

  create_table "data_collectors", :force => true do |t|
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
  end

  create_table "data_filters", :force => true do |t|
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

  create_table "inner_page_pages", :force => true do |t|
    t.integer  "inner_page_id"
    t.integer  "page_id"
    t.integer  "user_id"
    t.string   "uuid",          :limit => 36
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inner_page_pages", ["inner_page_id"], :name => "index_inner_page_pages_on_inner_page_id"
  add_index "inner_page_pages", ["page_id"], :name => "index_inner_page_pages_on_page_id"
  add_index "inner_page_pages", ["position"], :name => "index_inner_page_pages_on_position"

  create_table "inner_pages", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
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

  create_table "nces06_districts", :force => true do |t|
    t.text    "LEAID"
    t.text    "FIPST"
    t.text    "STID"
    t.text    "NAME"
    t.text    "PHONE"
    t.text    "MSTREE"
    t.text    "MCITY"
    t.text    "MSTATE"
    t.text    "MZIP"
    t.text    "MZIP4"
    t.text    "LSTREE"
    t.text    "LCITY"
    t.text    "LSTATE"
    t.text    "LZIP"
    t.text    "LZIP4"
    t.text    "TYPE"
    t.text    "UNION"
    t.text    "CONUM"
    t.text    "CONAME"
    t.text    "CSA"
    t.text    "CBSA"
    t.text    "METMIC"
    t.text    "MSC"
    t.text    "ULOCAL"
    t.text    "CDCODE"
    t.integer "LATCOD"
    t.integer "LONCOD"
    t.text    "BOUND"
    t.text    "GSLO"
    t.text    "GSHI"
    t.text    "AGCHRT"
    t.integer "SCH"
    t.integer "TEACH"
    t.integer "UG"
    t.integer "PK12"
    t.integer "MEMBER"
    t.integer "MIGRNT"
    t.integer "SPECED"
    t.integer "ELL"
    t.integer "PKTCH"
    t.integer "KGTCH"
    t.integer "ELMTCH"
    t.integer "SECTCH"
    t.integer "UGTCH"
    t.integer "TOTTCH"
    t.integer "AIDES"
    t.integer "CORSUP"
    t.integer "ELMGUI"
    t.integer "SECGUI"
    t.integer "TOTGUI"
    t.integer "LIBSPE"
    t.integer "LIBSUP"
    t.integer "LEAADM"
    t.integer "LEASUP"
    t.integer "SCHADM"
    t.integer "SCHSUP"
    t.integer "STUSUP"
    t.integer "OTHSUP"
    t.text    "IGSLO"
    t.text    "IGSHI"
    t.text    "ISCH"
    t.text    "ITEACH"
    t.text    "IUG"
    t.text    "IPK12"
    t.text    "IMEMB"
    t.text    "IMIGRN"
    t.text    "ISPEC"
    t.text    "IELL"
    t.text    "IPKTCH"
    t.text    "IKGTCH"
    t.text    "IELTCH"
    t.text    "ISETCH"
    t.text    "IUGTCH"
    t.text    "ITOTCH"
    t.text    "IAIDES"
    t.text    "ICOSUP"
    t.text    "IELGUI"
    t.text    "ISEGUI"
    t.text    "ITOGUI"
    t.text    "ILISPE"
    t.text    "ILISUP"
    t.text    "ILEADM"
    t.text    "ILESUP"
    t.text    "ISCADM"
    t.text    "ISCSUP"
    t.text    "ISTSUP"
    t.text    "IOTSUP"
  end

  create_table "nces06_schools", :force => true do |t|
    t.text    "NCESSCH"
    t.text    "FIPST"
    t.text    "LEAID"
    t.text    "SCHNO"
    t.text    "STID"
    t.text    "SEASCH"
    t.text    "LEANM"
    t.text    "SCHNAM"
    t.text    "PHONE"
    t.text    "MSTREE"
    t.text    "MCITY"
    t.text    "MSTATE"
    t.text    "MZIP"
    t.text    "MZIP4"
    t.text    "LSTREE"
    t.text    "LCITY"
    t.text    "LSTATE"
    t.text    "LZIP"
    t.text    "LZIP4"
    t.text    "TYPE"
    t.text    "STATUS"
    t.text    "ULOCAL"
    t.text    "LATCOD"
    t.text    "LONCOD"
    t.text    "CDCODE"
    t.text    "CONUM"
    t.text    "CONAME"
    t.integer "FTE"
    t.text    "GSLO"
    t.text    "GSHI"
    t.text    "LEVEL"
    t.text    "TITLEI"
    t.text    "STITLI"
    t.text    "MAGNET"
    t.text    "CHARTR"
    t.text    "SHARED"
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
    t.integer "PUPTCH"
    t.integer "TOTGRD"
    t.text    "IFTE"
    t.text    "IGSLO"
    t.text    "IGSHI"
    t.text    "ITITLI"
    t.text    "ISTITL"
    t.text    "IMAGNE"
    t.text    "ICHART"
    t.text    "ISHARE"
    t.text    "IFRELC"
    t.text    "IREDLC"
    t.text    "ITOTFR"
    t.text    "IMIGRN"
    t.text    "IPK"
    t.text    "IAMPKM"
    t.text    "IAMPKF"
    t.text    "IAMPKU"
    t.text    "IASPKM"
    t.text    "IASPKF"
    t.text    "IASPKU"
    t.text    "IHIPKM"
    t.text    "IHIPKF"
    t.text    "IHIPKU"
    t.text    "IBLPKM"
    t.text    "IBLPKF"
    t.text    "IBLPKU"
    t.text    "IWHPKM"
    t.text    "IWHPKF"
    t.text    "IWHPKU"
    t.text    "IKG"
    t.text    "IAMKGM"
    t.text    "IAMKGF"
    t.text    "IAMKGU"
    t.text    "IASKGM"
    t.text    "IASKGF"
    t.text    "IASKGU"
    t.text    "IHIKGM"
    t.text    "IHIKGF"
    t.text    "IHIKGU"
    t.text    "IBLKGM"
    t.text    "IBLKGF"
    t.text    "IBLKGU"
    t.text    "IWHKGM"
    t.text    "IWHKGF"
    t.text    "IWHKGU"
    t.text    "IG01"
    t.text    "IAM01M"
    t.text    "IAM01F"
    t.text    "IAM01U"
    t.text    "IAS01M"
    t.text    "IAS01F"
    t.text    "IAS01U"
    t.text    "IHI01M"
    t.text    "IHI01F"
    t.text    "IHI01U"
    t.text    "IBL01M"
    t.text    "IBL01F"
    t.text    "IBL01U"
    t.text    "IWH01M"
    t.text    "IWH01F"
    t.text    "IWH01U"
    t.text    "IG02"
    t.text    "IAM02M"
    t.text    "IAM02F"
    t.text    "IAM02U"
    t.text    "IAS02M"
    t.text    "IAS02F"
    t.text    "IAS02U"
    t.text    "IHI02M"
    t.text    "IHI02F"
    t.text    "IHI02U"
    t.text    "IBL02M"
    t.text    "IBL02F"
    t.text    "IBL02U"
    t.text    "IWH02M"
    t.text    "IWH02F"
    t.text    "IWH02U"
    t.text    "IG03"
    t.text    "IAM03M"
    t.text    "IAM03F"
    t.text    "IAM03U"
    t.text    "IAS03M"
    t.text    "IAS03F"
    t.text    "IAS03U"
    t.text    "IHI03M"
    t.text    "IHI03F"
    t.text    "IHI03U"
    t.text    "IBL03M"
    t.text    "IBL03F"
    t.text    "IBL03U"
    t.text    "IWH03M"
    t.text    "IWH03F"
    t.text    "IWH03U"
    t.text    "IG04"
    t.text    "IAM04M"
    t.text    "IAM04F"
    t.text    "IAM04U"
    t.text    "IAS04M"
    t.text    "IAS04F"
    t.text    "IAS04U"
    t.text    "IHI04M"
    t.text    "IHI04F"
    t.text    "IHI04U"
    t.text    "IBL04M"
    t.text    "IBL04F"
    t.text    "IBL04U"
    t.text    "IWH04M"
    t.text    "IWH04F"
    t.text    "IWH04U"
    t.text    "IG05"
    t.text    "IAM05M"
    t.text    "IAM05F"
    t.text    "IAM05U"
    t.text    "IAS05M"
    t.text    "IAS05F"
    t.text    "IAS05U"
    t.text    "IHI05M"
    t.text    "IHI05F"
    t.text    "IHI05U"
    t.text    "IBL05M"
    t.text    "IBL05F"
    t.text    "IBL05U"
    t.text    "IWH05M"
    t.text    "IWH05F"
    t.text    "IWH05U"
    t.text    "IG06"
    t.text    "IAM06M"
    t.text    "IAM06F"
    t.text    "IAM06U"
    t.text    "IAS06M"
    t.text    "IAS06F"
    t.text    "IAS06U"
    t.text    "IHI06M"
    t.text    "IHI06F"
    t.text    "IHI06U"
    t.text    "IBL06M"
    t.text    "IBL06F"
    t.text    "IBL06U"
    t.text    "IWH06M"
    t.text    "IWH06F"
    t.text    "IWH06U"
    t.text    "IG07"
    t.text    "IAM07M"
    t.text    "IAM07F"
    t.text    "IAM07U"
    t.text    "IAS07M"
    t.text    "IAS07F"
    t.text    "IAS07U"
    t.text    "IHI07M"
    t.text    "IHI07F"
    t.text    "IHI07U"
    t.text    "IBL07M"
    t.text    "IBL07F"
    t.text    "IBL07U"
    t.text    "IWH07M"
    t.text    "IWH07F"
    t.text    "IWH07U"
    t.text    "IG08"
    t.text    "IAM08M"
    t.text    "IAM08F"
    t.text    "IAM08U"
    t.text    "IAS08M"
    t.text    "IAS08F"
    t.text    "IAS08U"
    t.text    "IHI08M"
    t.text    "IHI08F"
    t.text    "IHI08U"
    t.text    "IBL08M"
    t.text    "IBL08F"
    t.text    "IBL08U"
    t.text    "IWH08M"
    t.text    "IWH08F"
    t.text    "IWH08U"
    t.text    "IG09"
    t.text    "IAM09M"
    t.text    "IAM09F"
    t.text    "IAM09U"
    t.text    "IAS09M"
    t.text    "IAS09F"
    t.text    "IAS09U"
    t.text    "IHI09M"
    t.text    "IHI09F"
    t.text    "IHI09U"
    t.text    "IBL09M"
    t.text    "IBL09F"
    t.text    "IBL09U"
    t.text    "IWH09M"
    t.text    "IWH09F"
    t.text    "IWH09U"
    t.text    "IG10"
    t.text    "IAM10M"
    t.text    "IAM10F"
    t.text    "IAM10U"
    t.text    "IAS10M"
    t.text    "IAS10F"
    t.text    "IAS10U"
    t.text    "IHI10M"
    t.text    "IHI10F"
    t.text    "IHI10U"
    t.text    "IBL10M"
    t.text    "IBL10F"
    t.text    "IBL10U"
    t.text    "IWH10M"
    t.text    "IWH10F"
    t.text    "IWH10U"
    t.text    "IG11"
    t.text    "IAM11M"
    t.text    "IAM11F"
    t.text    "IAM11U"
    t.text    "IAS11M"
    t.text    "IAS11F"
    t.text    "IAS11U"
    t.text    "IHI11M"
    t.text    "IHI11F"
    t.text    "IHI11U"
    t.text    "IBL11M"
    t.text    "IBL11F"
    t.text    "IBL11U"
    t.text    "IWH11M"
    t.text    "IWH11F"
    t.text    "IWH11U"
    t.text    "IG12"
    t.text    "IAM12M"
    t.text    "IAM12F"
    t.text    "IAM12U"
    t.text    "IAS12M"
    t.text    "IAS12F"
    t.text    "IAS12U"
    t.text    "IHI12M"
    t.text    "IHI12F"
    t.text    "IHI12U"
    t.text    "IBL12M"
    t.text    "IBL12F"
    t.text    "IBL12U"
    t.text    "IWH12M"
    t.text    "IWH12F"
    t.text    "IWH12U"
    t.text    "IUG"
    t.text    "IAMUGM"
    t.text    "IAMUGF"
    t.text    "IAMUGU"
    t.text    "IASUGM"
    t.text    "IASUGF"
    t.text    "IASUGU"
    t.text    "IHIUGM"
    t.text    "IHIUGF"
    t.text    "IHIUGU"
    t.text    "IBLUGM"
    t.text    "IBLUGF"
    t.text    "IBLUGU"
    t.text    "IWHUGM"
    t.text    "IWHUGF"
    t.text    "IWHUGU"
    t.text    "IMEMB"
    t.text    "IAM"
    t.text    "IAMALM"
    t.text    "IAMALF"
    t.text    "IAMALU"
    t.text    "IASIAN"
    t.text    "IASALM"
    t.text    "IASALF"
    t.text    "IASALU"
    t.text    "IHISP"
    t.text    "IHIALM"
    t.text    "IHIALF"
    t.text    "IHIALU"
    t.text    "IBLACK"
    t.text    "IBLALM"
    t.text    "IBLALF"
    t.text    "IBLALU"
    t.text    "IWHITE"
    t.text    "IWHALM"
    t.text    "IWHALF"
    t.text    "IWHALU"
    t.text    "IETH"
    t.text    "IPUTCH"
    t.text    "ITOTGR"
  end

  create_table "open_responses", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",             :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "prompt"
    t.string   "default_response"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  add_index "page_elements", ["embeddable_id"], :name => "index_page_elements_on_embeddable_id"
  add_index "page_elements", ["page_id"], :name => "index_page_elements_on_page_id"
  add_index "page_elements", ["position"], :name => "index_page_elements_on_position"

  create_table "pages", :force => true do |t|
    t.integer  "user_id"
    t.integer  "section_id"
    t.string   "uuid",         :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "probe_types", :force => true do |t|
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

  create_table "properties_versioned_jnlps", :id => false, :force => true do |t|
    t.integer "property_id"
    t.integer "versioned_jnlp_id"
  end

  create_table "raw_otmls", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",         :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "otml_content"
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
    t.integer  "user_id"
    t.integer  "activity_id"
    t.string   "uuid",         :limit => 36
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "xhtmls", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid",        :limit => 36
    t.string   "name"
    t.text     "description"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
