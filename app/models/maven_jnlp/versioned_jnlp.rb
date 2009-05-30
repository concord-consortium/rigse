class MavenJnlp::VersionedJnlp < ActiveRecord::Base
  set_table_name "maven_jnlp_versioned_jnlps"
  
  belongs_to :versioned_jnlp_url, :class_name => "MavenJnlp::VersionedJnlpUrl"
  has_one :maven_jnlp_family, :through => :versioned_jnlp_url, :class_name => "MavenJnlp::VersionedJnlpUrl"

  belongs_to :icon, :class_name => "MavenJnlp::Icon"

  has_and_belongs_to_many :properties, :class_name => "MavenJnlp::Property"
  has_and_belongs_to_many :jars, :class_name => "MavenJnlp::Jar"
  has_and_belongs_to_many :native_libraries, :class_name => "MavenJnlp::NativeLibrary"

  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name codebase href title vendor homepage description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  validates_presence_of :versioned_jnlp_url, :message => "association not specified" 
  
  after_create do |jnlp|
    jnlp_object = Jnlp::Jnlp.new(jnlp.versioned_jnlp_url.url)    
    jnlp.name                     = jnlp_object.name
    jnlp.main_class               = jnlp_object.main_class
    jnlp.argument                 = jnlp_object.argument
    jnlp.offline_allowed          = jnlp_object.offline_allowed
    jnlp.local_resource_signatures_verified = jnlp_object.local_resource_signatures_verified
    jnlp.include_pack_gzip        = jnlp_object.include_pack_gzip
    jnlp.spec                     = jnlp_object.spec
    jnlp.codebase                 = jnlp_object.codebase
    jnlp.href                     = jnlp_object.href
    jnlp.j2se_version             = jnlp_object.j2se_version
    jnlp.max_heap_size            = jnlp_object.max_heap_size
    jnlp.initial_heap_size        = jnlp_object.initial_heap_size
    jnlp.title                    = jnlp_object.title
    jnlp.vendor                   = jnlp_object.vendor
    jnlp.homepage                 = jnlp_object.homepage
    jnlp.description              = jnlp_object.description

    if icon_object = jnlp_object.icon
      icon = MavenJnlp::Icon.find_or_create_by_href_and_height_and_width(:href => icon_object.href, :height => icon_object.height, :width => icon_object.width)
      jnlp.icon = icon
    end
    
    jnlp_object.jars.each do |jar_object|
      attributes =  MavenJnlp::VersionedJnlp.resource_attributes(jar_object)
      unless jar = MavenJnlp::Jar.find(:first, :conditions => attributes)
        jar = MavenJnlp::Jar.create!(attributes)
      end
      jnlp.jars << jar
    end

    jnlp_object.nativelibs.each do |nativelib_object|
      attributes =  MavenJnlp::VersionedJnlp.resource_attributes(nativelib_object)
      unless native_library = MavenJnlp::NativeLibrary.find(:first, :conditions => attributes)
        native_library = MavenJnlp::NativeLibrary.create!(attributes)
      end
      jnlp.native_libraries << native_library      
    end

    jnlp_object.properties.each do |property_object|
      attributes = {
        :name  => property_object.name,
        :value => property_object.value,
        :os    => property_object.os
      }
      unless property = MavenJnlp::Property.find(:first, :conditions => attributes)
        property = MavenJnlp::Property.create!(attributes)
      end
      jnlp.properties << property
    end
    jnlp.save
  end

  def self.resource_attributes(resource_object)
    { :name               => resource_object.name,
      :main               => resource_object.main,
      :os                 => resource_object.os,
      :href               => resource_object.href,
      :size               => resource_object.size,
      :size_pack_gz       => resource_object.size_pack_gz,
      :signature_verified => resource_object.signature_verified,
      :version_str        => resource_object.version_str }
  end

end
