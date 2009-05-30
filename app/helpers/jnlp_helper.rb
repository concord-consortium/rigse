module JnlpHelper
  
  def jnlp_adaptor
    @jnlp_adaptor || @jnlp_adaptor = JnlpAdaptor.new
  end
  
  def resource_jars
    jnlp_adaptor.resource_jars
  end

  def linux_native_jars
    jnlp_adaptor.linux_native_jars
  end

  def macos_native_jars
    jnlp_adaptor.macos_native_jars
  end
  
  def windows_native_jars
    jnlp_adaptor.windows_native_jars
  end

  def system_properties
    jnlp_adaptor.system_properties
  end
  
  def jnlp_resources(xml, options = {})
    xml.resources {
      xml.j2se :version => "1.5+", 'max-heap-size' => "128m", 'initial-heap-size' => "32m"
      xml.jar :href => "net/sf/sail/sail-data-emf/sail-data-emf.jar", :main => true, :version => "0.1.0-20090506.165007-1170"
      resource_jars.each do |resource|
        xml.jar :href => resource[0], :version => resource[1]
      end
      system_properties(options[:authoring]).each do |property|
        xml.property(:name => property[0], :value => property[1])
      end
    }
  end

  def jnlp_resources_linux(xml)
    xml.resources(:os => "Linux") { 
      linux_native_jars.each do |resource|
        xml.nativelib :href => resource[0], :version => resource[1]
      end
    }
  end

  def jnlp_resources_macosx(xml)
    xml.resources(:os => "Mac OS X") { 
      macos_native_jars.each do |resource|
        xml.nativelib :href => resource[0], :version => resource[1]
      end
    }
  end

  def jnlp_resources_windows(xml)
    xml.resources(:os => "Windows") { 
      windows_native_jars.each do |resource|
        xml.nativelib :href => resource[0], :version => resource[1]
      end
    }
  end

end