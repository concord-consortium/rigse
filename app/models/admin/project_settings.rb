class Admin::ProjectSettings < ActiveRecord::Base
  set_table_name "admin_project_settings"

  belongs_to :admin_project, :class_name => "Admin::Project"
  belongs_to :default_admin_user, :class_name => "User", :foreign_key => "default_admin_user_id"
  belongs_to :default_maven_jnlp_server, :class_name => "MavenJnlp::MavenJnlpServer", :foreign_key => "default_maven_jnlp_server_id"
  belongs_to :default_maven_jnlp_family, :class_name => "MavenJnlp::MavenJnlpFamily", :foreign_key => "default_maven_jnlp_family_id"

  has_and_belongs_to_many :maven_jnlp_maven_jnlp_servers, :class_name => "MavenJnlp::MavenJnlpServer"
  has_and_belongs_to_many :maven_jnlp_maven_jnlp_families, :class_name => "MavenJnlp::MavenJnlpFamily"

  serialize :states_and_provinces
  serialize :active_school_levels
  serialize :active_grades

  def default_maven_jnlp
    {:server  => default_maven_jnlp_server,
     :family  => default_maven_jnlp_family,
     :version => default_maven_jnlp_version}
  end
end
