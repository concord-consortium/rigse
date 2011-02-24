class CreateAdminProjectSettings < ActiveRecord::Migration
  def self.up
    ##########################################
    # New tables                             #
    ##########################################
    create_table :admin_project_settings do |t|
      t.string  :top_level_container_name #Do we want to keep this?
      t.string  :site_name
      t.text    :description
      t.string  :help_email
      t.string  :theme #Should this be split into it's own table?
      t.integer :default_admin_user_id
      t.integer :default_maven_jnlp_family_id
      t.integer :default_maven_jnlp_server_id
      t.string  :default_maven_jnlp_version
      t.string  :site_url
      t.string  :runnables_use
      t.string  :site_district
      t.string  :site_school
      t.string  :runnable_mime_type
      t.boolean :use_gse
      t.boolean :enable_default_users
      t.text    :states_and_provinces #Duplicate property on the Admin::Project model. Possibly migrate it over.
      t.text    :active_school_levels
      t.timestamps
    end

    #create_table :state_provinces do |t|
      #t.string :name
    #end

    #create_table :sakai_instances do |t|
      #t.string :url
    #end

    ##########################################
    # Join tables                            #
    ##########################################
    create_table :admin_project_settings_portal_grade_levels do |t|
      t.references :admin_project_settings
      t.references :portal_grade_level
    end

    #create_table :admin_project_settings_state_provinces do |t|
      #t.references :admin_project_settings
      #t.references :state_province
    #end

    create_table :admin_project_settings_maven_jnlp_maven_jnlp_servers do |t|
      t.references :admin_project_settings
      t.references :maven_jnlp_maven_jnlp_servers
    end

    create_table :admin_project_settings_maven_jnlp_maven_jnlp_families do |t|
      t.references :admin_project_settings
      t.references :maven_jnlp_maven_jnlp_families
    end

    #For active_school_levels attribute, need to confirm this is correct
    #create_table :admin_project_settings_portal_schools do |t|
      #t.references :admin_project_settings
      #t.references :portal_school
    #end

    #create_table :admin_project_settings_sakai_instances do |t|
      #t.references :admin_project_settings
      #t.references :sakai_instance
    #end
  end

  def self.down
    drop_table :admin_project_settings_maven_jnlp_maven_jnlp_families
    drop_table :admin_project_settings_maven_jnlp_maven_jnlp_servers
    drop_table :admin_project_settings_portal_grade_levels
    drop_table :admin_project_settings
  end
end
