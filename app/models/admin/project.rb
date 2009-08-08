require 'fileutils'

class Admin::Project < ActiveRecord::Base
  set_table_name "admin_projects"
  
  belongs_to :user

  belongs_to :maven_jnlp_server, :class_name => "MavenJnlp::MavenJnlpServer"
  belongs_to :maven_jnlp_family, :class_name => "MavenJnlp::MavenJnlpFamily"

  serialize :states_and_provinces
 
  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}

  def before_save
    if snapshot_enabled
      self.jnlp_version_str = maven_jnlp_family.snapshot_version
    end
  end
  
  def after_save
    if name == APP_CONFIG[:site_name] && url == APP_CONFIG[:site_url]
      write_to_settings_yml
    end
    if self.enable_default_users
      User.unsuspend_default_users
    else
      User.suspend_default_users
    end
  end

  def write_to_settings_yml
    new_settings = generate_settings_yml
    # FileUtils.copy("#{RAILS_ROOT}/config/settings.yml", "#{RAILS_ROOT}/config/settings-backup.yml")
    File.open("#{RAILS_ROOT}/config/settings.yml", 'w') do |f|
      f.write new_settings
    end
  end

  def generate_settings_yml
    app_config = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")
    app_config[RAILS_ENV]['site_name'] = self.name
    app_config[RAILS_ENV]['site_url'] = self.url
    app_config[RAILS_ENV]['enable_default_users'] = self.enable_default_users
    app_config[RAILS_ENV]['description'] = self.description
    app_config[RAILS_ENV]['states_and_provinces'] = self.states_and_provinces
    app_config[RAILS_ENV]['default_maven_jnlp_server'] = self.maven_jnlp_server.name
    app_config[RAILS_ENV]['default_maven_jnlp_family'] = self.maven_jnlp_family.name
    if self.snapshot_enabled
      app_config[RAILS_ENV]['default_jnlp_version'] = 'snapshot'
    else
      app_config[RAILS_ENV]['default_jnlp_version'] = self.jnlp_version_str
    end
    app_config.to_yaml
  end
  
  def display_type
    self.default_project? ? 'Default ' : ''
  end
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    # Admin::Project.default_project
    def default_project
      name, url = default_project_name_url
      find_by_name_and_url(name, url)
    end
    
    def default_project_name_url
      [APP_CONFIG[:site_name], APP_CONFIG[:site_url]]
    end
    
    def display_name
      "Project"
    end
    
    def create_or_update__default_project_from_settings_yml
      name, url = default_project_name_url
      states_and_provinces = APP_CONFIG[:states_and_provinces]
      maven_jnlp_server = MavenJnlp::MavenJnlpServer.find_by_name(APP_CONFIG[:default_maven_jnlp_server])
      jnlp_family = maven_jnlp_server.maven_jnlp_families.find_by_name(APP_CONFIG[:default_maven_jnlp_family])
      jnlp_version_str = APP_CONFIG[:default_jnlp_version]
      enable_default_users = APP_CONFIG[:enable_default_users]

      if jnlp_version_str == 'snapshot'
        snapshot_enabled = true
        jnlp_family.update_snapshot_jnlp_url
        jnlp_url = jnlp_family.snapshot_jnlp_url
        jnlp_version_str = jnlp_url.version_str
      else
        snapshot_enabled = false
      end
      attributes = {
        :name => name,
        :url => url,
        :user => User.site_admin,
        :enable_default_users => enable_default_users,
        :states_and_provinces => states_and_provinces,
        :maven_jnlp_server => maven_jnlp_server,
        :maven_jnlp_family => jnlp_family,
        :jnlp_version_str => jnlp_version_str,
        :snapshot_enabled => snapshot_enabled
      }
      unless project = Admin::Project.find_by_name_and_url(name, url)
        project = Admin::Project.create!(attributes)
      end
      project.user = User.site_admin
      project.enable_default_users = enable_default_users
      project.states_and_provinces = states_and_provinces
      project.maven_jnlp_server = maven_jnlp_server
      project.maven_jnlp_family = jnlp_family
      project.jnlp_version_str = jnlp_version_str
      project.snapshot_enabled = snapshot_enabled
      project.save!
      project
    end
  end
  
  def default_project?
    default_name, default_url = Admin::Project.default_project_name_url
    self.name == default_name && self.url == default_url
  end
    
end
