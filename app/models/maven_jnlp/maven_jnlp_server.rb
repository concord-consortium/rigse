class MavenJnlp::MavenJnlpServer < ActiveRecord::Base
  set_table_name "maven_jnlp_maven_jnlp_servers"
  
  has_many :projects, :class_name => "Admin::Project"

  has_many :maven_jnlp_families, :class_name => "MavenJnlp::MavenJnlpFamily"
  
  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name host path}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    def generate_names_for_maven_jnlp_servers
      maven_jnlp_servers = APP_CONFIG[:maven_jnlp_servers]
      maven_jnlp_servers.each do |server|
        attrs = { :host => server[:host], :path => server[:path] }
        if mj_server = MavenJnlp::MavenJnlpServer.find(:first, :conditions => attrs)
          unless mj_server.name
            puts "MavenJnlpServer: name: #{server[:name]} => #{attrs.inspect}"
            mj_server.name = server[:name]
            mj_server.save!
          end
        end
      end
    end
    
  end

  def maven_jnlp_object
    @maven_jnlp_object || load_maven_jnlp_object
  end
  
  def load_maven_jnlp_object
    if File.exists?(maven_jnlp_object_path)
      @maven_jnlp_object = YAML.load(File.read(maven_jnlp_object_path))
    else
      update_maven_jnlp_object
    end
  end

  def update_maven_jnlp_object
    @maven_jnlp_object = Jnlp::MavenJnlp.new(host, path)
    save_maven_jnlp_object
  end

  def save_maven_jnlp_object
    File.open(maven_jnlp_object_path, 'w') do |f|
      f.write YAML.dump(@maven_jnlp_object)
    end
    @maven_jnlp_object
  end
  
  def maven_jnlp_object_path
    File.join(RAILS_ROOT, 'config', "maven_jnlp_object_#{id}.yaml")
  end
  
  def create_maven_jnlp_families
    maven_jnlp_families = APP_CONFIG[:maven_jnlp_families]
    maven_jnlp_object.maven_jnlp_families.each do |mjf_object|
      if self.maven_jnlp_families.find_by_url(mjf_object.url)
        puts "\nmaven_jnlp_family: #{mjf_object.url} "
        puts "already exists "
      elsif !maven_jnlp_families || maven_jnlp_families.include?(mjf_object.name)
        mjf = self.maven_jnlp_families.build(
          :name             => mjf_object.name,
          :url              => mjf_object.url,
          :snapshot_version => mjf_object.snapshot_version)
        mjf.save!
        puts "\nmaven_jnlp_family: #{mjf_object.url} "
        puts "current snapshot version: #{mjf_object.snapshot_version} "
        puts "generating #{mjf_object.versions.length} versioned_jnlp resources:"
        mjf.create_versioned_jnlp_urls(mjf_object)
        puts "\n\n"
      else
        puts "skipping maven_jnlp_family: #{mjf_object.url} "
      end
    end
  end
end
