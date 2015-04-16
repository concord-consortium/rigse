# locals
#   runnable
#   learner
#   authoring
#   teacher_mode
jnlp_headers(runnable)
config_url_options = {:format => :config}
installer_report_options = {}

if local_assigns[:jnlp_session]
  config_url_options[:jnlp_session] = jnlp_session.token
  installer_report_options[:jnlp_session_id] = jnlp_session.id
else
  # we should really stop putting the session in the jnlp
  config_url_options[Rails.application.config.session_options[:key]] = request.env["rack.session.options"][:id]
end

if(local_assigns[:learner])
  url_target = learner
else
  url_target = runnable
  config_url_options[:teacher_mode] = local_assigns[:teacher_mode]
end

xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
# hard code the codebase because the jar file versions are also hardcoded
xml.jnlp(:spec => "1.0+", :codebase => "http://#{current_settings.jnlp_cdn_hostname.presence || 'jars.dev.concord.org'}/dev4") { 
  jnlp_information(xml, local_assigns[:learner])
  xml.security {
    xml << "    <all-permissions />"
  }
  jnlp_mac_java_config(xml)

  xml.resources {
    xml.j2se :version => '1.5+', 'max-heap-size' => "512m", 'initial-heap-size' => "32m"
    # do not use version attributes so we can totally avoid all the jnlp jar versioning issues
    xml.jar :href=> "org/concord/utilities/response-cache/response-cache-0.1.0-20140107.154611-222.jar"
    xml.jar :href=> "org/concord/jnlp2shell/jnlp2shell-1.0-20140828.182415-470.jar", :main =>"true"
    system_properties(local_assigns).each do |property|
      xml.property(:name => property[0], :value => property[1])
    end
    xml.property :name=> "jnlp.vendor", :value => jnlp_installer_vendor
    xml.property :name=> "jnlp.product_name", :value => jnlp_installer_project
    xml.property :name=> "jnlp.product_version", :value => jnlp_installer_version
    old_versions = jnlp_installer_old_versions
    if old_versions.size > 0
      xml.property :name => "jnlp.product_old_versions", :value => old_versions.join(',')
    end

    # Someday we might want to cache some resources, but right now, we don't
    # xml.property :name=> "resource_loc", :value => "resources"

    xml.property :name=> "jnlp.cache_loc", :value => "jars"
    xml.property :name=> "jnlp.jnlp2shell.compact_paths", :value => "true"
    xml.property :name=> "jnlp.jnlp2shell.read_only", :value => "true"

    if(local_assigns[:learner])
      xml.property :name=> "jnlp.portalLearner", :value => learner.id
    end

    xml.property :name=> "jnlp.skip_not_found_dialog", :value => "true"
    xml.property :name=> "jnlp.test_jar_saving", :value => installer_report_url(installer_report_options)
    xml.property :name=> "jnlp.install_if_not_found", :value => "true"

    # include wrapped_jnlp so we know what jnlp to install from
    xml.property :name=> "jnlp.wrapped_jnlp", :value => current_settings.jnlp_url

    xml.property :name=> "jnlp.jnlp2shell.static_www", :value => "true"
    # if the cdn is set then tell jnlp2shell to use that as a mirror
    if current_settings.jnlp_cdn_hostname.present?
      xml.property :name=> "jnlp.jnlp2shell.mirror_host", :value => current_settings.jnlp_cdn_hostname
    end
  }

  xml << "  <application-desc main-class='org.concord.LaunchJnlp'>\n  "
  xml.argument polymorphic_url(url_target, config_url_options)
  xml << "  </application-desc>\n"
}
