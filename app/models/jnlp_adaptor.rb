class JnlpAdaptor
  
  attr_reader :jnlp
  attr_reader :jnlp_url
  attr_reader :net_logo_package_name

  OTRUNK_NLOGO_JAR_PACKAGE_MAP = {
    "otrunk-nlogo41" => "otrunknl41",
    "otrunk-nlogo4"  => "otrunknl4"
  }
  
  # Returns an array of the default maven_jnlp server,  family, and jnlp snampshot version info
  # 
  # Example:
  # 
  #   server, family, version = JnlpAdaptor.default_jnlp_info
  #
  #   server  # => {:path=>"/dev/org/concord/maven-jnlp/", :name=>"concord", :host=>"http://jnlp.concord.org"}
  #   family  # => "all-otrunk-snapshot"
  #   version # => "0.1.0-20091013.161730"
  #    
  def self.default_jnlp_info
    default_maven_jnlp = APP_CONFIG[:default_maven_jnlp]
    # => {:family=>"all-otrunk-snapshot", :version=>"snapshot", :server=>"concord"}
    server = APP_CONFIG[:maven_jnlp_servers].find { |s| s[:name] == default_maven_jnlp[:server] }
    # => {:path=>"/dev/org/concord/maven-jnlp/", :name=>"concord", :host=>"http://jnlp.concord.org"}
    family = default_maven_jnlp[:family]
    # => "all-otrunk-snapshot"
    version = default_maven_jnlp[:version]
    # => "snapshot"
    [server, family, version]
  end

  def self.jnlp_version
    @jnlp_version ||= default_jnlp_info[2]
  end

  def self.maven_jnlp_server
      server, family, version = default_jnlp_info
      MavenJnlp::MavenJnlpServer.find_by_name(server[:name])
  end

  def self.maven_jnlp_family
      server, family, version = default_jnlp_info
      jnlp_server = maven_jnlp_server
      return nil if jnlp_server.nil?

      jnlp_server.maven_jnlp_families.find_by_name(family)
  end

  def self.jnlp_version_str
    # instead of just returning the version string from the settings.yml
    # we need to get the family and depending on the that return the most
    # recent snapshot
    if jnlp_version == 'snapshot'
      # return the most recent snapshot_version that is in the database
      # don't do any network look ups here
      maven_jnlp_family.snapshot_version
    else
      jnlp_version
    end
  end

  def self.snapshot_enabled
    jnlp_version == 'snapshot'
  end

  def self.update_snapshot_version
    maven_jnlp_family.update_snapshot_jnlp_url
  end

  def initialize
    @default_maven_jnlp_server = JnlpAdaptor.maven_jnlp_server
    @jnlp_family = JnlpAdaptor.maven_jnlp_family

    # lets try not updating here so we can be more explicit about it somewhere else
    # @jnlp_family.update_snapshot_jnlp_url

    default_version_str = JnlpAdaptor.jnlp_version_str
    jnlp_url = @jnlp_family.versioned_jnlp_urls.find_by_version_str(default_version_str)
    @jnlp = jnlp_url.versioned_jnlp

    otrunk_nlogo_jars = @jnlp.jars.select { |j2| j2.name[/otrunk-nlogo.*?/] }
    if otrunk_nlogo_jars.empty?
      @net_logo_package_name = nil
    else
      @net_logo_package_name = JnlpAdaptor::OTRUNK_NLOGO_JAR_PACKAGE_MAP[otrunk_nlogo_jars.first.name]
    end
    
    @jnlp_url = @jnlp.versioned_jnlp_url.url
  end
  
  def resource_jars
    @jnlp.jars.collect do |jar|
      if jar.main
        [jar.href, jar.version_str, true]
      else
        [jar.href, jar.version_str]
      end
    end
  end
  
  def linux_native_jars
    @jnlp.native_libraries.find_all_by_os('linux').collect { |nl| [nl.href, nl.version_str] }
  end

  def macos_native_jars
    @jnlp.native_libraries.find_all_by_os('mac_os_x').collect { |nl| [nl.href, nl.version_str] }
  end
  
  def windows_native_jars
    @jnlp.native_libraries.find_all_by_os('windows').collect { |nl| [nl.href, nl.version_str] }
  end

  def system_properties
    jnlp_properties = @jnlp.properties.collect { |prop| [prop.name, prop.value] }
    custom_properties = [
     ['otrunk.view.export_image', 'true'],
     ['otrunk.view.status', 'true']
    ]
    jnlp_properties + custom_properties
  end
end
