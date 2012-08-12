# locals
#   runnable
#   learner
#   authoring
#   teacher_mode
jnlp_headers(runnable)
session_options = request.env["rack.session.options"]
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
# hard code the codebase because the jar file versions are also hardcoded
xml.jnlp(:spec => "1.0+", :codebase => "http://#{current_project.jnlp_cdn_hostname.presence || 'jnlp.concord.org'}/dev3") { 
  jnlp_information(xml, local_assigns[:learner])
  xml.security {
    xml << "    <all-permissions />"
  }
  jnlp_mac_java_config(xml)

  opportunistic_installer = current_project.opportunistic_installer?
  url_options = {Rails.application.config.session_options[:key] => session_options[:id]}
  if(local_assigns[:learner])
    url_target = learner
  else
    url_target = runnable
    url_options[:teacher_mode] = local_assigns[:teacher_mode]
  end
  
  jnlp = jnlp_adaptor.jnlp
  # from jnlpwrapper.concord.org
  #<jar href="org/concord/utilities/response-cache/response-cache.jar" version="0.1.0-20090728.205151-9"/>
  #<jar href="org/concord/jnlp2shell/jnlp2shell.jar" version="1.0-20090729.161746-166" main="true"/>
  #
  xml.resources {
    xml.j2se :version => jnlp.j2se_version, 'max-heap-size' => "#{jnlp.max_heap_size}m", 'initial-heap-size' => "#{jnlp.initial_heap_size}m"
    # do not use version attributes so we can totally avoid all the jnlp jar versioning issues
    xml.jar :href=> "org/concord/utilities/response-cache/response-cache-0.1.0-20110101.051026-218.jar"
    xml.jar :href=> "org/concord/jnlp2shell/jnlp2shell-1.0-20120516.210342-439.jar", :main =>"true"
    system_properties(local_assigns).each do |property|
      xml.property(:name => property[0], :value => property[1])
    end
    xml.property :name=> "vendor", :value => jnlp_installer_vendor
    xml.property :name=> "product_name", :value => jnlp_installer_project
    xml.property :name=> "product_version", :value => jnlp_installer_version
    old_versions = jnlp_installer_old_versions
    if old_versions.size > 0
      xml.property :name => "product_old_versions", :value => old_versions.join(',')
    end

    # after conversation w/ scott & stephen, dont think we need this.
    # xml.property :name=> "wrapped_jnlp", :value => options[:wrapped_jnlp_url]
    # xml.property :name=> "mangle_wrapped_jnlp", :value => "false"
    
    # Someday we might want to cache some resources, but right now, we don't
    # xml.property :name=> "resource_loc", :value => "resources"

    xml.property :name=> "cache_loc", :value => "jars"
    xml.property :name=> "jnlp2shell.compact_paths", :value => "true"
    xml.property :name=> "jnlp2shell.read_only", :value => "true"
    
    # check if the opportunistic installer is enabled
    # if so then skip the not found dialog
    # and set the not_found_url to be the jnlp url + session property
    if(opportunistic_installer)
      xml.property :name=> "skip_not_found_dialog", :value => "true"
      xml.property :name=> "not_found_url", :value => polymorphic_url(url_target, {:format => :jnlp}.merge(url_options))
      xml.property :name=> "test_jar_saving", :value => installer_report_url
      xml.property :name=> "install_if_not_found", :value => "true"

      # include wrapped_jnlp so we know what jnlp to install from
      xml.property :name=> "wrapped_jnlp", :value => jnlp_adaptor.jnlp_url

      # if the cdn is set then tell jnlp2shell to go static
      if current_project.jnlp_cdn_hostname.present?
        xml.property :name=> "jnlp2shell.static_www", :value => "true"
        xml.property :name=> "jnlp2shell.mirror_host", :value => current_project.jnlp_cdn_hostname
      end
    end
  }
  if(!opportunistic_installer)
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


  xml << "  <application-desc main-class='org.concord.LaunchJnlp'>\n  "
  xml.argument polymorphic_url(url_target, {:format => :config}.merge(url_options))
  xml << "  </application-desc>\n"
}
