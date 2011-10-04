module JnlpHelper
  
  def jnlp_adaptor
    @_jnlp_adaptor ||= JnlpAdaptor.new(current_project)
  end
  
  def jnlp_icon_url
    icon_prefix = case APP_CONFIG[:theme]
    when 'itsisu'
      'itsisu_'
    else
      ''
    end
    
    host = root_path(:only_path => false)[0..-2]
    host + path_to_image("#{icon_prefix}jnlp_icon.gif")
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
        ['otrunk.view.user_data_warning', 'true']
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
  
  # There might be issues with filname lengths on IE 6 & 7
  # see http://support.microsoft.com/kb/897168
  def smoosh_file_name(_name,length=28,missing_char="_")
    name = _name.strip.gsub(/[\s+|\/\(\)\:]/,missing_char)
    left_trunc = right_trunc = length/2
    name = "#{name[0,left_trunc]}#{missing_char}#{name[-right_trunc,right_trunc]}"
    return name.strip.gsub(/_+/,missing_char)
  end
  
  def jnlp_headers(runnable)
    response.headers["Content-Type"] = "application/x-java-jnlp-file"
    response.headers["Cache-Control"] = "max-age=1"
    response.headers["Last-Modified"] = runnable.updated_at.httpdate
    filename = smoosh_file_name("#{APP_CONFIG[:site_name]} #{runnable.class.name} #{short_name(runnable.name)}")
    response.headers["Content-Disposition"] = "inline; filename=#{filename}.jnlp"
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
      xml.icon :href => jnlp_icon_url, :height => "64", :width => "64"
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
    config = load_yaml("#{RAILS_ROOT}/config/installer.yml")
    config['shortname'] || "RITES"
  end
  
  # IMPORTANT: should match <project><version>XXXX</version></project> value
  # from bitrock installer config file: eg: projects/rites/rites.xml
  def jnlp_installer_version
    config = load_yaml("#{RAILS_ROOT}/config/installer.yml")
    config['version'] || "200912.2"
  end
  
  def jnlp_installer_not_found_url(os)
    "#{APP_CONFIG[:site_url]}/missing_installer/#{os}"
  end

  def jnlp_installer_resources(xml, options = {})
    jnlp = jnlp_adaptor.jnlp
    # from jnlpwrapper.concord.org
    #<jar href="org/concord/utilities/response-cache/response-cache.jar" version="0.1.0-20090728.205151-9"/>
    #<jar href="org/concord/jnlp2shell/jnlp2shell.jar" version="1.0-20090729.161746-166" main="true"/>
    #
    xml.resources {
      xml.j2se :version => jnlp.j2se_version, 'max-heap-size' => "#{jnlp.max_heap_size}m", 'initial-heap-size' => "#{jnlp.initial_heap_size}m"
      xml.jar :href=> "org/concord/utilities/response-cache/response-cache.jar", :version=> "0.1.0-20090728.205151-9"
      # xml.jar :href=> "org/concord/jnlp2shell/jnlp2shell.jar", :version=> "1.0-20091102.180724-197", :main =>"true"
      # jnlp2shell__V1.0-20110601.192832-412.jar
      xml.jar :href=> "org/concord/jnlp2shell/jnlp2shell.jar", :version=> "1.0-20110601.192832-412", :main =>"true"
      system_properties(options).each do |property|
        xml.property(:name => property[0], :value => property[1])
      end
      xml.property :name=> "vendor", :value => jnlp_installer_vendor
      xml.property :name=> "product_name", :value => jnlp_installer_project
      xml.property :name=> "product_version", :value => jnlp_installer_version
      # after conversation w/ scott & stephen, dont think we need this.
      # xml.property :name=> "wrapped_jnlp", :value => options[:wrapped_jnlp_url]
      # xml.property :name=> "mangle_wrapped_jnlp", :value => "false"
      
      # Someday we might want to cache some resources, but right now, we don't
      # xml.property :name=> "resource_loc", :value => "resources"

      xml.property :name=> "cache_loc", :value => "jars"
      xml.property :name=> "jnlp2shell.compact_paths", :value => "true"
      xml.property :name=> "jnlp2shell.read_only", :value => "true"
    }
    xml.resources(:os => "Linux") { 
      xml.property :name=> "not_found_url", :value => jnlp_installer_not_found_url("linux")
    }
    xml.resources(:os => "Mac OS X") { 
      xml.property :name=> "not_found_url", :value => jnlp_installer_not_found_url("osx")
    }
    xml.resources(:os => "Windows") { 
      xml.property :name=> "not_found_url", :value => jnlp_installer_not_found_url("windows")
    }
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
