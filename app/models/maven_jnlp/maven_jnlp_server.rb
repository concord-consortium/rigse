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
    maven_jnlp_object.maven_jnlp_families.each do |mjf_object|
      if self.maven_jnlp_families.find_by_url(mjf_object.url)
        puts "\nmaven_jnlp_family: #{mjf_object.url} "
        puts "already exists "
      else
        mjf = self.maven_jnlp_families.build(
          :name             => mjf_object.name,
          :url              => mjf_object.url,
          :snapshot_version => mjf_object.snapshot_version)
        mjf.save!
        puts "\n\nmaven_jnlp_family: #{mjf_object.url} "
        puts "generating versioned_jnlp resources:"
        mjf.create_versioned_jnlp_urls(mjf_object)
      end
    end
  end
end
