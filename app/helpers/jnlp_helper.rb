module JnlpHelper

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

  def jnlp_splash_url(learner = nil)
    # throw in a random element to the url so that it'll get requested every time
    opts = { :rand => UUIDTools::UUID.timestamp_create.hexdigest }
    opts[:learner_id] = learner if learner
    return banner_url(opts)
  end

  def pub_interval
    return Admin::Settings.pub_interval * 1000
  end

  def system_properties(options={})
    sysprops = [
      ['jnlp.otrunk.view.export_image', 'true'],
      ['jnlp.otrunk.view.status', 'true'],
    ]
    version = "#{current_settings.jnlp_url}"[/\/([^\/]*)\.jnlp/, 1]
    sysprops << ['jnlp.maven.jnlp.version', version] unless version.nil?
    if options[:authoring]
      additional_properties = [
        ['jnlp.otrunk.view.author', 'true'],
        ['jnlp.otrunk.view.mode', 'authoring'],
        ['jnlp.otrunk.remote_save_data', 'true'],
        ['jnlp.otrunk.rest_enabled', 'true'],
        ['jnlp.otrunk.remote_url', update_otml_url_for(options[:runnable], false)]
      ]
    elsif options[:learner]
      additional_properties = [
        ['jnlp.otrunk.view.mode', 'student'],
      ]
      if current_settings.use_periodic_bundle_uploading?
        # make sure the periodic bundle logger exists, just in case
        l = options[:learner]
        if l.student.user == current_visitor
          pbl = l.periodic_bundle_logger || Dataservice::PeriodicBundleLogger.create(:learner_id => l.id)
          additional_properties << ['jnlp.otrunk.periodic.uploading.enabled', 'true']
          additional_properties << ['jnlp.otrunk.periodic.uploading.url', dataservice_periodic_bundle_logger_periodic_bundle_contents_url(pbl)]
          additional_properties << ['jnlp.otrunk.periodic.uploading.interval', pub_interval]
          additional_properties << ['jnlp.otrunk.session_end.notification.url', dataservice_periodic_bundle_logger_session_end_notification_url(pbl)]
        end
      end
    else
      additional_properties = [
        ['jnlp.otrunk.view.mode', 'student'],
        ['jnlp.otrunk.view.no_user', 'true' ],
      ]
    end
    sysprops + additional_properties
  end

  def jnlp_headers(runnable)
    response.headers["Content-Type"] = "application/x-java-jnlp-file"

    # we don't want the jnlp to be cached because it contains session information for the current user
    # if a shared proxy caches it then multiple users will be loading and storing data in the same place
    NoCache.add_headers(response.headers)
    response.headers["Last-Modified"] = runnable.updated_at.httpdate
    response.headers["Content-Disposition"] = "inline; filename=#{APP_CONFIG[:theme]}_#{runnable.class.name.underscore}_#{short_name(runnable.name)}.jnlp"
  end

  def jnlp_information(xml, learner = nil)
    xml.information { 
      xml.title APP_CONFIG[:site_name]
      xml.vendor "Concord Consortium"
      xml.homepage :href => APP_CONFIG[:site_url]
      xml.description APP_CONFIG[:description]
      xml.icon :href => jnlp_icon_url, :height => "64", :width => "64"
      xml.icon :href => jnlp_splash_url(learner), :kind => "splash"
    }
  end

  ########################################
  ## TODO: These jnlp_installer_* methods
  ## should be encapsulated in some class
  ## and track things like jnlp / previous versions &etc.
  ##
  def jnlp_installer_vendor
    "ConcordConsortium"
  end

  #
  # convenient
  #
  def load_yaml(filename) 
    file_txt = "---"
    begin
      File.open(filename, "r") do |f|
        file_txt = f.read
      end
    rescue
    end
    return YAML::load(file_txt) || {}
  end

  # IMPORTANT: should match <project><name>XXXX</name></project> value
  # from bitrock installer
  def jnlp_installer_project
    config = load_yaml("#{::Rails.root.to_s}/config/installer.yml")
    config['shortname'] || "General"
  end

  # IMPORTANT: should match <project><version>XXXX</version></project> value
  # from bitrock installer config file: eg: projects/rites/rites.xml
  def jnlp_installer_version
    config = load_yaml("#{::Rails.root.to_s}/config/installer.yml")
    config['version'] || "1.0"
  end

  def jnlp_installer_old_versions
    config = load_yaml("#{::Rails.root.to_s}/config/installer.yml")
    config['old_versions'] || []
  end

  def jnlp_mac_java_config(xml)
    # If possible Force Mac OS X to use a 32bit Java 1.5 so that sensors are ensured to work
    # this bit of xml is actually parsed by the binary javaws program on OS X. The way javaws
    # evaulates this xml has changed over time. For example at one point it wasn't using a known arch for
    # which is why there is a non-arch resources element.
    # in recent versions of javaws, at least, I've found that it only does an order of precedence within a single
    # resources element. So for example
    #
    # <resources os="Mac OS X" arch="x86_64">
    #   <j2se version="1.7">
    # </resources>
    # <resources os="Mac OS X" arch="x86_64">
    #   <j2se version="1.6" java-vm-args="-d32">
    # </resources>
    #
    # for some reason it will always pass -d32 to the vm. If instead the xml is:
    #
    # <resources os="Mac OS X" arch="x86_64">
    #   <j2se version="1.7">
    #   <j2se version="1.6" java-vm-args="-d32">
    # </resources>
    #
    # then it will not pass the -d32 option
    xml.resources(:os => "Mac OS X", :arch => "ppc i386") {
      xml.j2se :version => "1.5", :"max-heap-size" => "512m", :"initial-heap-size" => "32m"
    }
    xml.resources(:os => "Mac OS X", :arch => "x86_64") {
      xml.j2se :version => "1.7", :"max-heap-size" => "512m", :"initial-heap-size" => "32m"
      xml.j2se :version => "1.5", :"max-heap-size" => "512m", :"initial-heap-size" => "32m", :"java-vm-args" => "-d32"
    }
    xml.resources(:os => "Mac OS X") {
      xml.j2se :version => "1.7", :"max-heap-size" => "512m", :"initial-heap-size" => "32m"
      xml.j2se :version => "1.6", :"max-heap-size" => "512m", :"initial-heap-size" => "32m", :"java-vm-args" => "-d32"
    }
  end

end
