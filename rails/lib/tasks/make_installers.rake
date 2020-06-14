require 'highline/import'
require 'fileutils'

namespace :build do
  namespace :installer do
    
    def check_dir_exists(dir)
      FileUtils::mkdir(dir) unless File.exists?(dir)
      dir
    end
    
    def bitrocket_installer_dir
      check_dir_exists("#{::Rails.root.to_s}/resources/bitrock_installer")
     end

    def installer_dest
      check_dir_exists("#{::Rails.root.to_s}/public/installers/")
    end

    def installer_config_xml
      "rites.xml"
    end

    def jnlps_config
      "jnlps.conf"
    end
    
    def bitrocket_builder_path
      app_path = ENV['BITROCK_INSTALLER']
      if RUBY_PLATFORM =~ /darwin/
        app_path ||= "/Applications/BitRock InstallBuilder Professional 7.2.0/bin/Builder.app"
        app_path += "/Contents/MacOS/installbuilder.sh"
      elsif RUBY_PLATFORM =~ /linux/
        app_path ||= "/opt/installbuilder-8.2.0"
        app_path += "/bin/builder"
      end
      app_path
    end
  
    def default_jnlp_url
      "#{APP_CONFIG[:site_url]}/investigations/#{Investigation.first.id}.jnlp"
    end
  
    def write_file_with_template_replacements(filename,template,replacements)
      File.open(template, "r") do |f|
        file_txt = f.read
        file_txt.gsub!(/\#\{([^\}]+)\}/) {|match| replacements[$1] || "" }
        File.open(filename, "w") do |f|
           f.write(file_txt)
        end
      end
    end
    
    def remove_otrunk_properties
      # <property value="true" name="otrunk.view.export_image"/>
      # <property value="true" name="otrunk.view.status"/>
      # <property value="student" name="otrunk.view.mode"/>
      # <property value="true" name="otrunk.view.no_user"/>
      jardir = "#{bitrocket_installer_dir}/jars"
      jnlp_file_name = %x[find #{jardir} -name \*.jnlp].chomp
      jnlp_data = File.open(jnlp_file_name).read
      regex = /<property.*name="otrunk.*"[^\/]*\/>/i
      jnlp_data.gsub!(regex,"")
      regex = /<application-desc main-class='net.sf.sail.emf.launch.EMFLauncher2'>(.*)<\/application-desc>/m
      jnlp_data.gsub!(regex,"<application-desc main-class='net.sf.sail.emf.launch.EMFLauncher2'><argument></argument></application-desc>")
      File.open(jnlp_file_name, "w") do |f|
        f.write(jnlp_data)
      end
    end
    def load_yaml(filename) 
      file_txt = ""
      File.open(filename, "r") do |f|
        file_txt = f.read
      end
      return YAML::load(file_txt)
    end
 
    def write_config(config, config_file="#{::Rails.root.to_s}/config/installer.yml")
      File.open(config_file, "w") { |f|
        f.write(YAML::dump(config))
      }
      write_file_with_template_replacements("#{bitrocket_installer_dir}/rites.xml","#{bitrocket_installer_dir}/template.xml",config)
      write_file_with_template_replacements("#{bitrocket_installer_dir}/jnlps.conf","#{bitrocket_installer_dir}/template.jnlps.conf",config)
    end
    
    # return a hash with the current config values
    # from the xml file
    def current_config_settings
      matches = {}
      File.open("#{bitrocket_installer_dir}/#{installer_config_xml}", "r") { |f|
        config_xml = f.read
        %w[shortname version].each do |k|
          if config_xml =~ /<#{k}>(.*)<\/#{k}>/i
            matches[k] = $1
          end
        end
      }
      File.open("#{bitrocket_installer_dir}/#{jnlps_config}", "r") { |f|
        jnlp_config = f.read
        if jnlp_config =~ /JNLP_URLS="(.*)"/i
          matches['jnlp_config'] = $1
        end
      }
      return matches
    end
    
    desc 'create a new release specification interactively'
    task :new_release => ["#{::Rails.root.to_s}/config/installer.yml"] do
      config = {}
      puts <<-HERE_DOC
        bumping the version... (TODO: create some helper )
        for now: modify the following files by hand:
            app/helpers/jnlp_helper.rb
            #{bitrocket_installer_dir}/#{installer_config_xml}
            #{bitrocket_installer_dir}/jnlps.conf"
      HERE_DOC
      config = load_yaml("#{::Rails.root.to_s}/config/installer.yml")
      %w[shortname version jnlp_config].each do |k|
        config[k] = ask("value for #{k}") { |q| q.default = config[k] }
      end
      write_config(config)
    end
    
    desc 'automagically create a new release'
    task :bump_release => ["#{::Rails.root.to_s}/config/installer.yml"]  do
       filename = "#{::Rails.root.to_s}/config/installer.yml"
       config = load_yaml(filename)
       date,version = config['version'].split(".")
       version = version.to_i
       today = Date.today.strftime("%Y%m")
       if date != today
         date = today
         version = 0
       end
       version = version + 1
       version_string = "#{date}.#{"%02d" % version}"
       puts "old: #{config['version']}"
       puts "new: #{version_string}"
       config['version'] = version_string
       write_config(config)
    end
    
    desc 'generate the installer configuration files from the config/installer.yml'
    task :generate_installer_config => ["#{::Rails.root.to_s}/config/installer.yml"]  do
       filename = "#{::Rails.root.to_s}/config/installer.yml"
       config = load_yaml(filename)
       write_config(config)
    end

    desc 'clean jar and installers folder'
    task :clean do
      puts "cleaning the jar folder"
      %x[rm -rf #{bitrocket_installer_dir}/jars]
      %x[rm -rf #{bitrocket_installer_dir}/installers]
      %x[rm -f "#{bitrocket_installer_dir}/rites.xml"]
      %x[rm -f "#{bitrocket_installer_dir}/jnlps.conf"]
    end
    
    file "#{::Rails.root.to_s}/config/installer.yml" do
      configs = current_config_settings
      %w[shortname version jnlp_config].each do |k|
        configs[k] = ask("value for #{k}") { |q| q.default = configs[k] }
      end
      File.open("#{::Rails.root.to_s}/config/installer.yml", "w") { |f|
        f.write(YAML::dump(configs))
      }
    end
    
    
    desc 'cache jars'
    task :cache_jars => [:clean, :generate_installer_config] do
      puts "Caching jar resources"
      %x[mkdir -p #{bitrocket_installer_dir}/jars/]
      puts %x[cd #{bitrocket_installer_dir}; ./scripts/cache-jars.sh ]
      remove_otrunk_properties
    end

    desc 'build the osx installer'
    task :build_osx do
      puts "building osx installer"
      puts %x[cd #{bitrocket_installer_dir}; '#{bitrocket_builder_path}' build #{installer_config_xml} osx]
      %x[cp #{bitrocket_installer_dir}/installers/*.dmg #{installer_dest}]
    end
    task :build_mac => :build_osx

    desc 'build the windows installer'
    task :build_win do
      puts "building win installer"
      puts %x[cd #{bitrocket_installer_dir}; '#{bitrocket_builder_path}' build #{installer_config_xml} windows]
      %x[cp #{bitrocket_installer_dir}/installers/*.exe #{installer_dest}]
    end

    desc 'build the osx installer'
    task :cache_and_build_osx => [:cache_jars, :build_osx]

    desc 'build the windows installer'
    task :cache_and_build_win => [:cache_jars, :build_win]
    
    desc 'build all installers: will automatically clean up, recache jars, and bump version numbers.'
    task :build_all => [:bump_release, :cache_and_build_win, :cache_and_build_osx]

    desc 'build all installers: will automatically clean up, reache jars. It does NOT bump version numbers.'
    task :rebuild_all => [:cache_and_build_win, :cache_and_build_osx]
  end
end
