class JnlpAdaptor
  
  attr_reader :jnlp
  
  def initialize
    @all_otrunk_snapshot_family = MavenJnlp::MavenJnlpFamily.find_by_name('all-otrunk-snapshot')
    @jnlp = @all_otrunk_snapshot_family.snapshot_jnlp_url.versioned_jnlp
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
     ['otrunk.view.author', 'true'],
     ['_otrunk.view.debug', 'true'],
     ['otrunk.view.mode', 'student'],
     ['otrunk.view.status', 'true']
    ]
    jnlp_properties + custom_properties
  end
end
