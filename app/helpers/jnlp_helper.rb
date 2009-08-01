module JnlpHelper
  
  def full_url_for_image(path)
    host = root_path(:only_path => false)[0..-2]
    host + path_to_image(path)
  end
  
  def render_jnlp(runnable)
    # FIXME can't figure out why otml_url_for, doesn't work here
    # otml_url_for(runnable)
    url = polymorphic_url(runnable, :format =>  :otml, :teacher_mode => params[:teacher_mode])
    escaped_otml_url = URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)

    sds_connection = Portal::SdsConnect::Connect    
    config_url = sds_connection.offering_url(sds_connection.config['default_offering_id']) + 
      "/config/#{sds_connection.config['default_workgroup_id']}" + 
      "/0/view?sailotrunk.hidetree=false&amp;sailotrunk.otmlurl=#{escaped_otml_url}"
    render( :layout => false, :partial => "shared/jnlp", 
      :locals => { 
        :teacher_mode => params[:teacher_mode], 
        :runnable_object => runnable, 
        :config_url => config_url
      } 
    )
  end
  
  def render_learner_jnlp(learner)
    # FIXME can't figure out why otml_url_for, doesn't work here
    # otml_url_for(runnable)
    otml_url = polymorphic_url(learner.offering.runnable, :format =>  :otml)
    otml_url = URI.escape(otml_url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
    config_url = learner.sds_config_url('sailotrunk.otmlurl' => otml_url, :savedata => true)
    
    @learner = true
    
    render( :layout => false, :partial => "shared/jnlp",
            :locals => { :runnable_object => learner.offering.runnable, :config_url => config_url } )
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
        ['otrunk.remote_url', update_otml_url_for(options[:runnable_object], false)]
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
        if resource[2]
          xml.jar :href => resource[0], :main => true, :version => resource[1]
        else
          xml.jar :href => resource[0], :version => resource[1]
        end
      end
      system_properties(options).each do |property|
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