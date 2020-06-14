module Shim
  module Admin
    class Project < ActiveRecord::Base
      self.table_name = "admin_projects"
    end
  end

  module MavenJnlp
    class VersionedJnlpUrl < ActiveRecord::Base
      self.table_name = "maven_jnlp_versioned_jnlp_urls"
    end

    class MavenJnlpFamily < ActiveRecord::Base
      self.table_name = "maven_jnlp_maven_jnlp_families"
      has_many :versioned_jnlp_urls, :class_name => "Shim::MavenJnlp::VersionedJnlpUrl"
    end

    class MavenJnlpServer < ActiveRecord::Base
      self.table_name = "maven_jnlp_maven_jnlp_servers"
      has_many :maven_jnlp_families, :class_name => "Shim::MavenJnlp::MavenJnlpFamily"
    end
  end

  class JnlpAdaptor
    def self.jnlp_url
      default_maven_jnlp = APP_CONFIG[:default_maven_jnlp]
      server = APP_CONFIG[:maven_jnlp_servers].find { |s| s[:name] == default_maven_jnlp[:server] }
      family = default_maven_jnlp[:family]
      version = default_maven_jnlp[:version]

      jnlp_server = ::Shim::MavenJnlp::MavenJnlpServer.find_by_name(server[:name])
      ($stderr.puts("No jnlp_server! #{server[:name]}"); return nil) if jnlp_server.nil?
      jnlp_family = jnlp_server.maven_jnlp_families.find_by_name(family)

      default_version_str = (version == "snapshot" ? jnlp_family.snapshot_version : version)
      jnlp_url = jnlp_family.versioned_jnlp_urls.find_by_version_str(default_version_str)
      ($stderr.puts("No jnlp_url!"); return nil) if jnlp_url.nil?

      return jnlp_url.url
    end
  end
end

class AddJnlpUrlToAdminProject < ActiveRecord::Migration
  def up
    add_column :admin_projects, :jnlp_url, :string

    # Find current jnlp url and stick it in the new jnlp_url field of each admin::project
    url = Shim::JnlpAdaptor.jnlp_url rescue nil
    if url
      Shim::Admin::Project.all.each do |p|
        p.update_column(:jnlp_url, url)
      end
    end

    # Delete all of the old jnlp tables
    drop_table :jars_versioned_jnlps
    drop_table :maven_jnlp_icons
    drop_table :maven_jnlp_jars
    drop_table :maven_jnlp_maven_jnlp_families
    drop_table :maven_jnlp_maven_jnlp_servers
    drop_table :maven_jnlp_native_libraries
    drop_table :maven_jnlp_properties
    drop_table :maven_jnlp_versioned_jnlp_urls
    drop_table :maven_jnlp_versioned_jnlps
    drop_table :native_libraries_versioned_jnlps
    drop_table :properties_versioned_jnlps
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new
  end

end
