module JnlpHelper
  
  def full_url_for_image(path)
    host = root_path(:only_path => false)[0..-2]
    host + path_to_image(path)
  end
  
  def render_jnlp(runnable)
    # FIXME can't figure out why otml_url_for, doesn't work here
    # otml_url_for(runnable)
    url = polymorphic_url(runnable, :format =>  :dynamic_otml, :teacher_mode => params[:teacher_mode])
    escaped_otml_url = URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)

    sds_connection = Portal::SdsConnect::Connect    
    config_url = sds_connection.offering_url(sds_connection.config['default_offering_id']) + 
      "/config/#{sds_connection.config['default_workgroup_id']}" + 
      "/0/view?sailotrunk.hidetree=false&amp;sailotrunk.otmlurl=#{escaped_otml_url}"
    render( :layout => false, :partial => "shared/jnlp", 
      :locals => { 
        :teacher_mode => params[:teacher_mode], 
        :runnable => runnable, 
        :config_url => config_url
      } 
    )
  end

  def resource_jars
    @jnlp_adaptor.resource_jars
  end

  def linux_native_jars
    @jnlp_adaptor.linux_native_jars
  end

  def macos_native_jars
    @jnlp_adaptor.macos_native_jars
  end
  
  def windows_native_jars
    @jnlp_adaptor.windows_native_jars
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
    @jnlp_adaptor.system_properties + additional_properties
  end
  
  def jnlp_resources(xml, options = {})
    jnlp = @jnlp_adaptor.jnlp
    xml.resources {
      xml.j2se :version => jnlp.j2se_version, 'max-heap-size' => "#{jnlp.max_heap_size}m", 'initial-heap-size' => "#{jnlp.initial_heap_size}m"
      resource_jars.each do |resource|
        if resource[2] && (!options[:data_test])
          xml.jar :href => resource[0], :main => true, :version => resource[1]
        else
          xml.jar :href => resource[0], :version => resource[1]
        end
      end
      if options[:data_test]
        jnlp_test_resources(xml)
      end
      system_properties(options).each do |property|
        xml.property(:name => property[0], :value => property[1])
      end
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
  
  # IMPORTANT: should match <project><name>XXXX</name></project> value
  # from bitrock installer
  def jnlp_installer_project
    "RITES"
  end
  
  # IMPORTANT: should match <project><version>XXXX</version></project> value
  # from bitrock installer config file: eg: projects/rites/rites.xml
  def jnlp_installer_version
    "200912.1"
  end
  
  def jnlp_installer_not_found_url
    "#{APP_CONFIG[:site_url]}/missing_installer"
  end

  def jnlp_installer_resources(xml, options = {})
    jnlp = @jnlp_adaptor.jnlp
    # from jnlpwrapper.concord.org
    #<jar href="org/concord/utilities/response-cache/response-cache.jar" version="0.1.0-20090728.205151-9"/>
    #<jar href="org/concord/jnlp2shell/jnlp2shell.jar" version="1.0-20090729.161746-166" main="true"/>
    #
    xml.resources {
      xml.j2se :version => jnlp.j2se_version, 'max-heap-size' => "#{jnlp.max_heap_size}m", 'initial-heap-size' => "#{jnlp.initial_heap_size}m"
      xml.jar :href=> "org/concord/utilities/response-cache/response-cache.jar", :version=> "0.1.0-20090728.205151-9"
      xml.jar :href=> "org/concord/jnlp2shell/jnlp2shell.jar", :version=> "1.0-20090729.161746-166", :main =>"true"
      system_properties(options).each do |property|
        xml.property(:name => property[0], :value => property[1])
      end
      xml.property :name=> "vendor", :value => jnlp_installer_vendor
      xml.property :name=> "product_name", :value => jnlp_installer_project
      xml.property :name=> "product_version", :value => jnlp_installer_version
      xml.property :name=> "not_found_url", :value => jnlp_installer_not_found_url
      xml.property :name=> "wrapped_jnlp", :value => options[:wrapped_jnlp_url]
      xml.property :name=> "mangle_wrapped_jnlp", :value => "false"
      xml.property :name=> "resource_loc", :value => "resources" # do we do this? Not sure
      xml.property :name=> "cache_loc", :value => "jars"
      xml.property :name=> "jnlp2shell.compact_paths", :value => "true"
      xml.property :name=> "jnlp2shell.read_only", :value => "true"
    }
  end
  
  
  ##
  ##
  ## /TODO
  #########################################
  
  

  def jnlp_test_resources(xml)  
    # TODO: Dynamically configure this:
    xml.jar :href=> "org/concord/testing/gui/gui-0.1.0-20091201.182019-8.jar",  :main => "true"
    xml.jar :href=> "org/easytesting/fest-swing-junit-4.3.1/fest-swing-junit-4.3.1-1.2a3.jar"
    xml.jar :href=> "org/easytesting/fest-swing/fest-swing-1.2a3.jar"
    xml.jar :href=> "org/easytesting/fest-util/fest-util-1.1.jar"
    xml.jar :href=> "org/easytesting/fest-assert/fest-assert-1.1.jar"
    xml.jar :href=> "org/easytesting/fest-reflect/fest-reflect-1.1.jar"
    xml.jar :href=> "net/jcip/jcip-annotations/jcip-annotations-1.0.jar"
    xml.jar :href=> "swinghelper/debug/debug-1.0.jar"
    xml.jar :href=> "org/easytesting/fest-swing-junit/fest-swing-junit-1.2a3.jar"
    xml.jar :href=> "commons-codec/commons-codec/commons-codec-1.3.jar"
    xml.jar :href=> "org/easytesting/fest-test/fest-test-1.2.jar"
    xml.jar :href=> "org/easytesting/fest-mocks/fest-mocks-1.1.jar"
    xml.jar :href=> "org/easymock/easymockclassextension/easymockclassextension-2.4.jar"
    xml.jar :href=> "org/easymock/easymock/easymock-2.4.jar"
    xml.jar :href=> "cglib/cglib-nodep/cglib-nodep-2.1_3.jar"
    xml.jar :href=> "org/easytesting/fest-assembly/fest-assembly-1.0.jar"
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