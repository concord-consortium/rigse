class JnlpAdaptor
  
  attr_reader :jnlp
  
  def initialize
    @default_maven_jnlp_server = MavenJnlp::MavenJnlpServer.find_by_name(APP_CONFIG[:default_maven_jnlp_server])
    @jnlp_family = @default_maven_jnlp_server.maven_jnlp_families.find_by_name(APP_CONFIG[:default_maven_jnlp_family])
    @jnlp_family.update_snapshot_jnlp_url
    @jnlp = @jnlp_family.snapshot_jnlp_url.versioned_jnlp
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
