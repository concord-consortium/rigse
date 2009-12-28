require 'highline/import'

namespace :build do
  namespace :installer do
    def bitrocket_installer_dir
      "#{RAILS_ROOT}/resources/bitrock_installer"
    end

    def installer_dest
      "#{RAILS_ROOT}/public/installers/"
    end

    def installer_config_xml
      "rites.xml"
    end

    def jnlps_config
      "jnlps.conf"
    end
    
    def bitrocket_builder_path
      app_path = ENV['BITROCK_INSTALLER'] || "/Applications/BitRock InstallBuilder Enterprise 6.2.5/bin/Builder.app"
      app_path + "/Contents/MacOS/installbuilder.sh"
    end
  
    def default_jnlp_url
      "#{APP_CONFIG[:site_url]}/investigations/#{Investigation.first.id}.jnlp"
    end
  
    def write_file_with_template_replacements(filename,template,replacements)
      File.open(template, "r") do |f|
        file_txt = f.read
        replacements.each_pair do |k,v|
          file_txt.gsub!(/\#{#{k}}/,v)
        end
        File.open(filename, "w") do |f|
           f.write(file_txt)
        end
      end
    end
    
    def load_yaml(filename) 
      file_txt = ""
      File.open(filename, "r") do |f|
        file_txt = f.read
      end
      return YAML::load(file_txt)
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
    
    desc 'create a new release'
    task :new_release => ["#{RAILS_ROOT}/config/installer.yml"] do
      config = {}
      puts <<-HERE_DOC
        bumping the version... (TODO: create some helper )
        for now: modify the following files by hand:
            app/helpers/jnlp_helper.rb
            #{bitrocket_installer_dir}/#{installer_config_xml}
            #{bitrocket_installer_dir}/jnlps.conf"
      HERE_DOC
      config = load_yaml("#{RAILS_ROOT}/config/installer.yml")
      %w[shortname version jnlp_config].each do |k|
        config[k] = ask("value for #{k}") { |q| q.default = config[k] }
      end
      File.open("#{RAILS_ROOT}/config/installer.yml", "w") { |f|
        f.write(YAML::dump(config))
      }
      cp "#{RAILS_ROOT}/config/installer.yml", "#{RAILS_ROOT}/config/installer.yml.backup"
      cp "#{bitrocket_installer_dir}/rites.xml", "#{bitrocket_installer_dir}/rites.xml.backup"
      cp "#{bitrocket_installer_dir}/jnlps.conf", "#{bitrocket_installer_dir}/jnlps.conf.backup"
      write_file_with_template_replacements("#{bitrocket_installer_dir}/rites.xml","#{bitrocket_installer_dir}/template.xml",config)
      write_file_with_template_replacements("#{bitrocket_installer_dir}/jnlps.conf","#{bitrocket_installer_dir}/template.jnlps.conf",config)
    end
    
    desc 'clean jar and installers folder'
    task :clean do
      puts "cleaning the jar folder"
      %x[rm -rf #{bitrocket_installer_dir}/jars]
      %x[rm -rf #{bitrocket_installer_dir}/installers]
    end
    
    file "#{RAILS_ROOT}/config/installer.yml" do
      configs = current_config_settings
      %w[shortname version jnlp_config].each do |k|
        configs[k] = ask("value for #{k}") { |q| q.default = configs[k] }
      end
      File.open("#{RAILS_ROOT}/config/installer.yml", "w") { |f|
        f.write(YAML::dump(configs))
      }
    end
    
    
    desc 'cache jars'
    task :cache_jars => :clean do
      puts "Caching jar resources"
      %x[mkdir -p #{bitrocket_installer_dir}/jars/]
      %x[cd #{bitrocket_installer_dir}; ./scripts/cache-jars.sh ]
    end
      
  
    desc 'build the osx installer'
    task :build_osx => :cache_jars do
      puts "building osx installer"
      %x[cd #{bitrocket_installer_dir}; '#{bitrocket_builder_path}' build #{installer_config_xml} osx]
      %x[cd #{bitrocket_installer_dir}; '#{bitrocket_builder_path}' build #{installer_config_xml} osx]
      %x[cp #{bitrocket_installer_dir}/installers/*.dmg #{installer_dest}]
      puts "Now you might want to scp the installers to their home directory on the server. try something like this:"
      config = load_yaml("#{RAILS_ROOT}/config/installer.yml")
      jnlp_url = config['jnlp_config'] || "http://rites-investigations.concord.org/investigations/409.jnlp"
      if jnlp_url =~ /^.*?:\/\/(.*)?(\/.*)/
        hostname = $1
      else
        hostname = 'rites-investigations.concord.org'
      end
      puts "scp #{bitrocket_installer_dir}/installers/*.dmg #{hostname}:/web/staging/rites/current/public/installers/"
      %x[cp #{bitrocket_installer_dir}/installers/*.dmg #{installer_dest}]
    end

    desc 'build the windows installer'
    task :build_win => :cache_jars do
      puts "building win installer"
      %x[cd #{bitrocket_installer_dir}; '#{bitrocket_builder_path}' build #{installer_config_xml} windows]
      %x[cp #{bitrocket_installer_dir}/installers/*.exe #{installer_dest}]
    end
    
    desc 'build all installers'
    task :build_all => [:build_win, :build_osx]

    task :buid_mac => :build_osx
  end
end