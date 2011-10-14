module JnlpHelper
  
  def jnlp_adaptor
    @_jnlp_adaptor ||= JnlpAdaptor.new(current_project)
  end
  
  def full_url_for_image(path)
    host = root_path(:only_path => false)[0..-2]
    host + path_to_image(path)
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

  def system_properties(options={})
    if options[:authoring]
      additional_properties = [
        ['otrunk.view.author', 'true'],
        ['otrunk.view.mode', 'authoring'],
        ['otrunk.remote_save_data', 'true'],
        ['otrunk.rest_enabled', 'true'],
        ['otrunk.remote_url', update_otml_url_for(options[:runnable], false)]
      ]
    elsif options[:learner]
      additional_properties = [
        ['otrunk.view.mode', 'student'],
      ]
    else
      additional_properties = [
        ['otrunk.view.mode', 'student'],
        ['otrunk.view.no_user', 'true' ],
      ]
    end
    jnlp_adaptor.system_properties + additional_properties
  end
  
  def jnlp_jar(xml, resource, check_for_main=true)
    if resource[2] && check_for_main
      # TODO: refactor how jar versions (or lack therof) are dealt with
      if resource[1]    # is there a version attribute?
        xml.jar :href => resource[0], :main => true, :version => resource[1]
      else
        xml.jar :href => resource[0], :main => true
      end
    else
      if resource[1]    # is there a version attribute?
        xml.jar :href => resource[0], :version => resource[1]
      else
        xml.jar :href => resource[0]
      end
    end
  end
  
  def jnlp_j2se(xml, jnlp)
    xml.j2se :version => jnlp.j2se_version, 'max-heap-size' => "#{jnlp.max_heap_size}m", 'initial-heap-size' => "#{jnlp.initial_heap_size}m"
  end
  
  def jnlp_os_specific_j2ses(xml, jnlp)
    if jnlp.j2se_version == 'mac_os_x'
      xml.resources {
        xml.j2se :version => jnlp.j2se_version('mac_os_x'), 'max-heap-size' => "#{jnlp.max_heap_size('mac_os_x')}m", 'initial-heap-size' => "#{jnlp.initial_heap_size('mac_os_x')}m"
      }
    end
    if jnlp.j2se_version == 'windows'
      xml.resources {
        xml.j2se :version => jnlp.j2se_version('windows'), 'max-heap-size' => "#{jnlp.max_heap_size('windows')}m", 'initial-heap-size' => "#{jnlp.initial_heap_size('windows')}m"
      }
    end
    if jnlp.j2se_version == 'linux'
      xml.resources {
        xml.j2se :version => jnlp.j2se_version('linux'), 'max-heap-size' => "#{jnlp.max_heap_size('linux')}m", 'initial-heap-size' => "#{jnlp.initial_heap_size('linux')}m"
      }
    end
  end
  
  def jnlp_resources(xml, options = {})
    jnlp = jnlp_adaptor.jnlp
    xml.resources {
      jnlp_j2se(xml, jnlp)
      resource_jars.each do |resource|
        jnlp_jar(xml, resource)
      end
      system_properties(options).each do |property|
        xml.property(:name => property[0], :value => property[1])
      end
      jnlp_os_specific_j2ses(xml, jnlp)
    }
  end
  
  def jnlp_testing_adaptor
    @_jnlp_testing_adaptor ||= JnlpTestingAdaptor.new
  end
  
  def jnlp_testing_resources(xml, options = {})
    jnlp = jnlp_adaptor.jnlp
    jnlp_for_testing = jnlp_testing_adaptor.jnlp
    xml.resources {
      jnlp_j2se(xml, jnlp)
      resource_jars.each do |resource|
        jnlp_jar(xml, resource, false)
      end
      jnlp_testing_adaptor.resource_jars.each do |resource|
        jnlp_jar(xml, resource)
      end
      system_properties(options).each do |property|
        xml.property(:name => property[0], :value => property[1])
      end
      jnlp_os_specific_j2ses(xml, jnlp)
    }
  end
  
  def jnlp_headers(runnable)
    response.headers["Content-Type"] = "application/x-java-jnlp-file"
    
    # we don't want the jnlp to be cached because it contains session information for the current user
    # if a shared proxy caches it then multiple users will be loading and storing data in the same place
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    response.headers["Last-Modified"] = runnable.updated_at.httpdate
    response.headers["Content-Disposition"] = "inline; filename=#{APP_CONFIG[:theme]}_#{runnable.class.name.underscore}_#{short_name(runnable.name)}.jnlp"
  end
  
  def config_headers(runnable)
    response.headers["Content-Type"] = "application/xml"
    response.headers["Cache-Control"] = "max-age=1"
  end
  
  
  def jnlp_information(xml)
    xml.information { 
      xml.title current_project.name
      xml.vendor "Concord Consortium"
      xml.homepage :href => APP_CONFIG[:site_url]
      xml.description APP_CONFIG[:description]
      xml.icon :href => full_url_for_image("sail_orangecirc_64.gif"), :height => "64", :width => "64"
    }
  end
  
  ########################################
  ## TODO: These jnlp_installer_* methods
  ## should be encapsulated in some class
  ## and track things like jnlp / previous versions &etc.
  ##
  def jnlp_installer_vendor
    "Concord Consortium".gsub(/\s+/,"")
  end
  
  #
  # convinient
  #
  def load_yaml(filename) 
    file_txt = ""
    File.open(filename, "r") do |f|
      file_txt = f.read
    end
    return YAML::load(file_txt)
  end
  
  # IMPORTANT: should match <project><name>XXXX</name></project> value
  # from bitrock installer
  def jnlp_installer_project
    config = load_yaml("#{::Rails.root.to_s}/config/installer.yml")
    config['shortname'] || "RITES"
  end
  
  # IMPORTANT: should match <project><version>XXXX</version></project> value
  # from bitrock installer config file: eg: projects/rites/rites.xml
  def jnlp_installer_version
    config = load_yaml("#{::Rails.root.to_s}/config/installer.yml")
    config['version'] || "200912.2"
  end
  
  def jnlp_installer_not_found_url(os)
    "#{APP_CONFIG[:site_url]}/missing_installer/#{os}"
  end

  def jnlp_resources_linux(xml)
    xml.resources(:os => "Linux") { 
      linux_native_jars.each do |resource|
        xml.nativelib :href => resource[0], :version => resource[1]
      end
    }
  end
  
  def jnlp_mac_java_config(xml)
    jnlp = jnlp_adaptor.jnlp
    # Force Mac OS X to use Java 1.5 so that sensors are ensured to work
    xml.resources(:os => "Mac OS X", :arch => "ppc i386") {
      xml.j2se :version => "1.5", :"max-heap-size" => "#{jnlp.max_heap_size}m", :"initial-heap-size" => "32m"
    }
    xml.resources(:os => "Mac OS X", :arch => "x86_64") {
      xml.j2se :version => "1.5", :"max-heap-size" => "#{jnlp.max_heap_size}m", :"initial-heap-size" => "32m", :"java-vm-args" => "-d32"
    } 
    xml.resources(:os => "Mac OS X") {
      xml.j2se :version => "1.6", :"max-heap-size" => "#{jnlp.max_heap_size}m", :"initial-heap-size" => "32m", :"java-vm-args" => "-d32"
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
