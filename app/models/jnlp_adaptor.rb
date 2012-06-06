class JnlpAdaptor
  
  attr_reader :jnlp
  attr_reader :jnlp_url
  attr_reader :net_logo_package_name

  OTRUNK_NLOGO_JAR_PACKAGE_MAP = {
    "otrunk-nlogo41" => "otrunknl41",
    "otrunk-nlogo4"  => "otrunknl4"
  }
  
  def initialize(project=Admin::Project.default_project)
    @default_maven_jnlp_server = project.maven_jnlp_server
    @jnlp_family = project.maven_jnlp_family
    @jnlp_family.update_snapshot_jnlp_url
    default_version_str = project.jnlp_version_str
    if project.snapshot_enabled
      @jnlp = @jnlp_family.snapshot_jnlp_url.versioned_jnlp
    else
      jnlp_url = @jnlp_family.versioned_jnlp_urls.find_by_version_str(default_version_str)
      if jnlp_url.nil?
        # this can happen if the family is changed but the version is not changed to a valid one
        # we could just take the first versioned_jnlp_url, but that causes strange behavior because
        # the @jnlp doesn't match the project.jnlp_version_str, 
        throw "Cannot find versioned jnlp: #{project.maven_jnlp_family.name}:#{default_version_str}"
      end
      @jnlp = jnlp_url.versioned_jnlp
    end
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
