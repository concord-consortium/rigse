class JnlpTestingAdaptor
  
  attr_reader :jnlp
  
  def initialize
    @jnlp_family = MavenJnlp::MavenJnlpFamily.find_by_name("gui-testing")
    if @jnlp_family
      @jnlp = @jnlp_family.update_snapshot_jnlp_url.versioned_jnlp
    else
      Rails.logger.warn("unable to load gui-testing jnlp family... ")
      Rails.logger.warn("try rake rigse:jnlp:generate_maven_jnlp_resources if you want to run gui-testing")
    end
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
