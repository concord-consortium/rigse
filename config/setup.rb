require 'rubygems'
require 'fileutils'
require 'yaml'
require 'erb'

APPLICATION = "'RITES Investigations'"
puts "\nInitial setup of #{APPLICATION} Rails application ...\n"

JRUBY = defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'
RAILS_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
APP_DIR_NAME = File.basename(RAILS_ROOT)

# Add the unpacked gems in vendor/gems to the $LOAD_PATH
Dir["#{RAILS_ROOT}/vendor/gems/**"].each do |dir| 
  $LOAD_PATH << File.expand_path(File.directory?(lib = "#{dir}/lib") ? lib : dir)
end

require 'uuidtools'
require 'highline/import'

def jruby_system_command
  JRUBY ? "jruby -S" : ""
end

def gem_install_command_strings(missing_gems)
  command = JRUBY ? "  jruby -S gem install " : "  sudo ruby gem install "
  command + missing_gems.collect {|g| "#{g[0]} -v'#{g[1]}'"}.join(' ') + "\n"
end

def rails_file_path(*args)
  File.join([RAILS_ROOT] + args)
end

def rails_file_exists?(*args)
  File.exists?(rails_file_path(args))
end

@db_config_path                = rails_file_path(%w{config database.yml})
@db_config_sample_path         = rails_file_path(%w{config database.sample.yml})
@settings_config_path          = rails_file_path(%w{config settings.yml})
@settings_config_sample_path   = rails_file_path(%w{config settings.sample.yml})
@rinet_data_config_path        = rails_file_path(%w{config rinet_data.yml})
@rinet_data_config_sample_path = rails_file_path(%w{config rinet_data.sample.yml})
@mailer_config_path            = rails_file_path(%w{config mailer.yml})
@mailer_config_sample_path     = rails_file_path(%w{config mailer.sample.yml})

@db_sample_config              = YAML::load(IO.read(@db_config_sample_path))
@settings_sample_config        = YAML::load(IO.read(@settings_config_sample_path))
@rinet_data_sample_config      = YAML::load(IO.read(@rinet_data_config_sample_path))
@mailer_sample_config          = YAML::load(IO.read(@mailer_config_sample_path))

@new_database_yml_created = false
@new_settings_yml_created = false
@new_rinet_data_yml_created = false
@new_mailer_yml_created = false

def copy_file(source, destination)

  puts <<HEREDOC
  copying: #{source}
       to: #{destination}

HEREDOC
  FileUtils.cp(source, destination)
end

@missing_gems = []

# These gems need to be installed with the Ruby VM for the web application
if JRUBY 
  @gems_needed_at_start = [
    ['rake', '>=0.8.7'],
    ['activerecord-jdbcmysql-adapter', '>=0.9.2'],
    ['jruby-openssl', '>=0.5.2']
  ]
else
  @gems_needed_at_start = [['mysql', '>= 2.7']]
end

@gems_needed_at_start.each do |gem_name_and_version|
  begin
    gem gem_name_and_version[0], gem_name_and_version[1]
  rescue Gem::LoadError
    @missing_gems << gem_name_and_version
  end
  begin
    require gem_name_and_version[0]
  rescue LoadError
  end
end

if @missing_gems.length > 0
  message = "\n\n*** Please install the following gems: (#{@missing_gems.join(', ')}) and run config/setup.rb again.\n"
  message << "\n#{gem_install_command_strings(@missing_gems)}\n"
  raise message
end

# returns true if @db_name_prefix on entry == @db_name_prefix on exit
# false otherwise
def confirm_database_name_prefix_user_password
  original_db_name_prefix = @db_name_prefix
  puts <<HEREDOC

The default prefix for specifying the database names will be: #{@db_name_prefix}.

You can specify a different prefix for the database names:

HEREDOC
  @db_name_prefix = ask("  database name prefix: ") { |q| q.default = @db_name_prefix }
  if @db_name_prefix == original_db_name_prefix
    @db_user = ask("  database username: ") { |q| q.default = 'root' }
    @db_password = ask("  database password: ") { |q| q.default = 'password' }
    true
  else
    false
  end
end

def create_new_database_yml
  raise "the instance variable @db_name_prefix must be set before calling create_new_database_yml" unless @db_name_prefix

  @db_config = @db_config_sample
  %w{development test staging production}.each do |env|
    @db_config[env]['database'] = "#{@db_name_prefix}_#{env}"
    @db_config[env]['user'] = @db_user
    @db_config[env]['password'] = @db_password
  end
  %w{itsi ccportal}.each do |external_db|
    @db_config[external_db]['user'] = @db_user
    @db_config[external_db]['password'] = @db_password
  end

  puts <<HEREDOC

       creating: #{@db_config_path}
  from template: #{@db_config_sample_path}

  using database name prefix: #{@db_name_prefix}

HEREDOC
  File.open(@db_config_path, 'w') {|f| f.write @db_config.to_yaml }
end

def create_new_settings_yml
  @settings_config = @settings_config_sample
  puts <<HEREDOC

       creating: #{@settings_config_path}
  from template: #{@settings_config_sample_path}

HEREDOC
  File.open(@settings_config_path, 'w') {|f| f.write @settings_config.to_yaml }
end

def create_new_mailer_yml
  @mailer_config = @mailer_config_sample
  puts <<HEREDOC

       creating: #{@mailer_config_path}
  from template: #{@mailer_config_sample_path}

HEREDOC
  File.open(@mailer_config_path, 'w') {|f| f.write @mailer_config.to_yaml }
end

def create_new_rinet_data_yml
  @rinet_data_config = @rinet_data_sample_config
  puts <<HEREDOC

       creating: #{@rinet_data_config_path}
  from template: #{@rinet_data_config_sample_path}

HEREDOC
  File.open(@rinet_data_config_path, 'w') {|f| f.write @rinet_data_config.to_yaml }
end

# 
# check for git submodules
#
def check_for_git_submodules
  git_modules_path = File.join(rails_file_path, '.gitmodules')
  if File.exists?(git_modules_path)
    git_modules = File.read(git_modules_path)
    git_submodule_paths = git_modules.grep(/path = .*/) { |path| path[/path = (.*)/, 1] }
    unless git_submodule_paths.all? { |path| File.exists?(path) }
      puts <<HEREDOC

Initializing git submodules ...

HEREDOC
      `git submodule init`
      `git submodule update`
    end
  end
end

#
# check for config/database.yml
#
def check_for_config_database_yml

  unless File.exists?(@db_config_path)
    puts <<HEREDOC

  The Rails database configuration file does not yet exist.

HEREDOC
    @db_name_prefix = APP_DIR_NAME.gsub(/\W/, '_')
    confirm_database_name_prefix_user_password
    create_new_database_yml
    @new_database_yml_created = true
  end
end

#
# check for config/settings.yml
#
def check_for_config_settings_yml
  unless File.exists?(@settings_config_path)
    puts <<HEREDOC

  The Rails application settings file does not yet exist.

HEREDOC
    create_new_settings_yml
  else
    @settings_config = YAML::load(IO.read(@settings_config_path))
      puts <<HEREDOC

  The Rails application settings file exists, lookking for possible updates ...

HEREDOC
    
    %w{development staging production}.each do |env|
      puts "\nchecking environment: #{env}\n"
      unless @settings_config[env]['states_and_provinces']
        puts <<HEREDOC

  The states_and_provinces parameter does not yet exist in the #{env} section of settings.yml

  Copying the values in the sample: #{@settings_sample_config[env]['states_and_provinces'].join(', ')} into settings.yml.

HEREDOC
        @settings_config[env]['states_and_provinces'] = @settings_sample_config[env]['states_and_provinces']
      end

      unless @settings_config[env]['active_grades']
        puts <<HEREDOC

  The active_grades parameter does not yet exist in the #{env} section of settings.yml

  Copying the values in the sample: #{@settings_sample_config[env]['active_grades'].join(', ')} into settings.yml.

HEREDOC
        @settings_config[env]['active_grades'] = @settings_sample_config[env]['active_grades']
      end

      unless @settings_config[env]['active_school_levels']
        puts <<HEREDOC

  The active_school_levels parameter does not yet exist in the #{env} section of settings.yml

  Copying the values in the sample: #{@settings_sample_config[env]['active_school_levels'].join(', ')} into settings.yml.

HEREDOC
        @settings_config[env]['active_school_levels'] = @settings_sample_config[env]['active_school_levels']
      end

      unless @settings_config[env]['valid_sakai_instances']
        puts <<HEREDOC

  The valid_sakai_instances parameter does not yet exist in the #{env} section of settings.yml

  Copying the values in the sample: #{@settings_sample_config[env]['valid_sakai_instances'].join(', ')} into settings.yml.

HEREDOC
        @settings_config[env]['valid_sakai_instances'] = @settings_sample_config[env]['valid_sakai_instances']
      end
    end
  end
end

#
# check for config/mailer.yml
#
def check_for_config_mailer_yml
  unless File.exists?(@mailer_config_path)
    puts <<HEREDOC

  The Rails mailer configuration file does not yet exist.

HEREDOC
    create_new_mailer_yml
  end
end

#
# check for config/rinet_data.yml
#
def check_for_config_rinet_data_yml
  unless File.exists?(@rinet_data_config_path)
    puts <<HEREDOC

  The RITES RINET CSV import configuration file does not yet exist.

HEREDOC
    create_new_rinet_data_yml
    @new_rinet_data_yml_created = true
  end
end

#
# check for log/development.log
#
def check_for_log_development_log
  @dev_log_path = rails_file_path(%w{log development.log})

  unless File.exists?(@dev_log_path)
    puts <<HEREDOC

  The Rails development log: 

    #{@dev_log_path} does not yet exist.

    #{@dev_log_path} created and permission set to 666

HEREDOC

    FileUtils.mkdir(rails_file_path("log")) unless File.exists?(rails_file_path("log"))
    FileUtils.touch(@dev_log_path)
    FileUtils.chmod(0666, @dev_log_path)
  end
end

#
# check for config/initializers/site_keys.rb
#
def check_for_config_initializers_site_keys_rb
  site_keys_path = rails_file_path(%w{config initializers site_keys.rb})

  unless File.exists?(site_keys_path)
    puts <<HEREDOC

  The Rails site keys authentication tokens file does not yet exist: 

    new #{site_keys_path} created.

    If you have copied a production database from another app instance you will
    need to have the same site keys authentication tokens in order for the existing
    User passwords to work.
    
    If you have ssh access to the production deploy site you can install a copy 
    with this capistrano task:

      cap production db:copy_remote_site_keys

HEREDOC

  site_key = UUIDTools::UUID.timestamp_create.to_s

    site_keys_rb = <<HEREDOC
  REST_AUTH_SITE_KEY         = '#{site_key}'
  REST_AUTH_DIGEST_STRETCHES = 10
HEREDOC

    File.open(site_keys_path, 'w') {|f| f.write site_keys_rb }
  end
end

#
# update config/database.yml
#
def update_config_database_yml
  @db_config = YAML::load(IO.read(@db_config_path))
  @db_name_prefix = @db_config['development']['database'][/(.*)_development/, 1]

  puts <<HEREDOC
----------------------------------------

Updating the Rails database configuration file: config/database.yml

Specify values for the mysql database name, username and password for the 
development staging and production environments.

Here are the current settings in config/database.yml:

#{@db_config.to_yaml} 
HEREDOC
  unless agree("Accept defaults? (y/n) ")
    create_new_database_yml unless @new_database_yml_created || confirm_database_name_prefix_user_password 

    %w{development test production}.each do |env|
      puts "\nSetting parameters for the #{env} database:\n\n"
      @db_config[env]['database'] = ask("  database name: ") { |q| q.default = @db_config[env]['database'] }
      @db_config[env]['username'] = ask("       username: ") { |q| q.default = @db_config[env]['username'] }
      @db_config[env]['password'] = ask("       password: ") { |q| q.default = @db_config[env]['password'] }
      @db_config[env]['adaptor'] = "<% if RUBY_PLATFORM =~ /java/ %>jdbcmysql<% else %>mysql<% end %>"
    end

    puts <<HEREDOC

If you have access to a ITSI database for importing ITSI Activities into RITES 
specify the values for the mysql database name, host, username, password, and asset_url.

HEREDOC

    puts "\nSetting parameters for the ITSI database:\n\n"
    @db_config['itsi']['database']  = ask("  database name: ") { |q| q.default = @db_config['itsi']['database'] }
    @db_config['itsi']['host']      = ask("           host: ") { |q| q.default = @db_config['itsi']['host']  }
    @db_config['itsi']['username']  = ask("       username: ") { |q| q.default = @db_config['itsi']['username'] }
    @db_config['itsi']['password']  = ask("       password: ") { |q| q.default = @db_config['itsi']['password'] }
    @db_config['itsi']['asset_url'] = ask("      asset url: ") { |q| q.default = @db_config['itsi']['asset_url'] }
    @db_config['itsi']['adaptor'] = "<% if RUBY_PLATFORM =~ /java/ %>jdbcmysql<% else %>mysql<% end %>"

    puts <<HEREDOC

If you have access to a CCPortal database that indexes ITSI Activities into sequenced Units 
specify the values for the mysql database name, host, username, password.

HEREDOC

    puts "\nSetting parameters for the CCPortal database:\n\n"
    @db_config['ccportal']['database']  = ask("  database name: ") { |q| q.default = @db_config['ccportal']['database'] }
    @db_config['ccportal']['host']      = ask("           host: ") { |q| q.default = @db_config['ccportal']['host']  }
    @db_config['ccportal']['username']  = ask("       username: ") { |q| q.default = @db_config['ccportal']['username'] }
    @db_config['ccportal']['password']  = ask("       password: ") { |q| q.default = @db_config['ccportal']['password'] }
    @db_config['ccportal']['adaptor'] = "<% if RUBY_PLATFORM =~ /java/ %>jdbcmysql<% else %>mysql<% end %>"

    puts <<HEREDOC

    Here is the updated database configuration:
    #{@db_config.to_yaml} 
HEREDOC

    if agree("OK to save to config/database.yml? (y/n): ")
      File.open(@db_config_path, 'w') {|f| f.write @db_config.to_yaml }
    end
  end
end

#
# update config/rinet_data.yml
#
def update_config_rinet_data_yml
  @rinet_data_config = YAML::load(IO.read(@rinet_data_config_path))

  puts <<HEREDOC
----------------------------------------

Updating the RINET CSV Account import configuration file: config/rinet_data.yml

Specify values for the host, username and password for the RINET SFTP
site to download Sakai account data in CSV format.

Here are the current settings in config/rinet_data.yml:

#{@rinet_data_config.to_yaml} 
HEREDOC
  unless agree("Accept defaults? (y/n) ")
    create_new_rinet_data_yml unless @new_rinet_data_yml_created
    
    %w{development test staging production}.each do |env|
      puts "\nSetting parameters for the #{env} rinet_data:\n"
      @rinet_data_config[env]['host']     = ask("         RINET host: ") { |q| q.default = @rinet_data_config[env]['host'] }
      @rinet_data_config[env]['username'] = ask("     RINET username: ") { |q| q.default = @rinet_data_config[env]['username'] }
      @rinet_data_config[env]['password'] = ask("     RINET password: ") { |q| q.default = @rinet_data_config[env]['password'] }
      puts
    end

    puts <<HEREDOC

    Here is the updated rinet_data configuration:
    #{@rinet_data_config.to_yaml} 
HEREDOC

    if agree("OK to save to config/rinet_data.yml? (y/n): ")
      File.open(@rinet_data_config_path, 'w') {|f| f.write @rinet_data_config.to_yaml }
    end
  end
end


def get_include_otrunk_examples_settings(env)
  include_otrunk_examples = @settings_config[env]['include_otrunk_examples']
  puts <<HEREDOC

Processing and importing of otrunk-examples can be enabled or disabled.
It is currently #{include_otrunk_examples ? 'disabled' : 'enabled' }.

HEREDOC
  @settings_config[env]['include_otrunk_examples'] = agree("Include otrunk-examples? (y/n) ") { |q| q.default = (include_otrunk_examples ? 'y' : 'n') }
end

def get_states_and_provinces_settings(env)
  states_and_provinces = (@settings_config[env]['states_and_provinces'] || []).join(' ')
  puts <<HEREDOC

Detailed data are imported for the following US schools and district:

  #{states_and_provinces}
 
List state or province abbreviations for the locations you want imported. 
Use two-character capital letter abreviations and delimit multiple items with spaces.

HEREDOC
  states_and_provinces = @settings_config[env]['states_and_provinces'].join(' ')
  states_and_provinces =  ask("   states_and_provinces: ") { |q| q.default = states_and_provinces }
  @settings_config[env]['states_and_provinces'] =  states_and_provinces.split  
end

def get_active_grades_settings(env)
  active_grades = (@settings_config[env]['active_grades'] || []).join(' ')
  puts <<HEREDOC

The following is a list of the active grade:

  #{active_grades}

List active grades for this application instance. 

Use any of the following: 

  K 1 2 3 4 5 6 7 8 9 10 11 12
  
and delimit multiple active grades with a space character.

HEREDOC
  active_grades =  ask("      active_grades: ") { |q| q.default = active_grades }
  @settings_config[env]['active_grades'] =  active_grades.split  
end

def get_active_school_levels(env)
  active_school_levels = (@settings_config[env]['active_school_levels'] || []).join(' ')
  puts <<HEREDOC

The following is a list of the active school levels:

  #{active_school_levels}

List active school levels for this application instance. 

Use any of the following: 

  1 2 3 4

and delimit multiple active school levels with a space character.

School level.  The following codes are used for active school levels:
 
  1 = Primary (low grade = PK through 03; high grade = PK through 08)
  2 = Middle (low grade = 04 through 07; high grade = 04 through 09)
  3 = High (low grade = 07 through 12; high grade = 12 only
  4 = Other (any other configuration not falling within the above three categories, including ungraded)

HEREDOC
  active_school_levels =  ask("   active_school_levels: ") { |q| q.default = active_school_levels }
  @settings_config[env]['active_school_levels'] =  active_school_levels.split  
end

def get_valid_sakai_instances(env)
  puts <<HEREDOC

Specify the sakai server urls from which it is ok to receive linktool requests.
Delimit multiple items with spaces.

HEREDOC
  sakai_instances = @settings_config[env]['valid_sakai_instances'].join(' ')
  sakai_instances =  ask("   valid_sakai_instances: ") { |q| q.default = sakai_instances }
  @settings_config[env]['valid_sakai_instances'] = sakai_instances.split
end

def get_maven_jnlp_settings(env)
  puts <<HEREDOC

  Specify the maven_jnlp server used for providing jnlps and jars dor running Java OTrunk applications.

HEREDOC
  maven_jnlp_server = @settings_config[env]['maven_jnlp_servers'][0]
  maven_jnlp_server[:host] =  ask("   host: ") { |q| q.default = maven_jnlp_server[:host] }
  maven_jnlp_server[:path] =  ask("   path: ") { |q| q.default = maven_jnlp_server[:path] }
  maven_jnlp_server[:name] =  ask("   name: ") { |q| q.default = maven_jnlp_server[:name] }
  @settings_config[env]['maven_jnlp_servers'][0] = maven_jnlp_server
  @settings_config[env]['default_maven_jnlp_server'] = maven_jnlp_server[:name]
  @settings_config[env]['default_maven_jnlp_family'] =  ask("   default_maven_jnlp_family: ") { |q| q.default = @settings_config[env]['default_maven_jnlp_family'] }  

  maven_jnlp_families = (@settings_config[env]['maven_jnlp_families'] || []).join(' ')
  puts <<HEREDOC

  The following is a list of the active maven_jnlp_families:

    #{maven_jnlp_families}

  Specify which maven_jnlp_families to include. Enter nothing to include all 
  the maven_jnlp_families. Delimit multiple items with spaces.

HEREDOC
  maven_jnlp_families =  ask("   active_school_levels: ") { |q| q.default = maven_jnlp_families }
  @settings_config[env]['maven_jnlp_families'] =  maven_jnlp_families.split
  puts <<HEREDOC
  
  Specify the default_jnlp_version to use:

HEREDOC
  @settings_config[env]['default_jnlp_version'] =  ask("   default_jnlp_version: ") { |q| q.default = @settings_config[env]['default_jnlp_version'] }  
end

#
# update config/settings.yml
#
def update_config_settings_yml
  puts <<HEREDOC
----------------------------------------

Updating the application settings configuration file: config/settings.yml

Specify general application settings values: site url, site name, and admin name, email, login
for the development staging and production environments.

If you are doing development locally you may want to use one database for development and production.
Some of the importing scripts run much faster in production mode.

HEREDOC

  puts <<HEREDOC

Here are the current settings in config/settings.yml:

#{@settings_config.to_yaml} 
HEREDOC
  unless agree("Accept defaults? (y/n) ")

    %w{development staging production}.each do |env|
      puts "\n#{env}:\n"
      @settings_config[env]['site_url'] =         ask("            site url: ") { |q| q.default = @settings_config[env]['site_url'] }
      @settings_config[env]['site_name'] =        ask("           site_name: ") { |q| q.default = @settings_config[env]['site_name'] }
      @settings_config[env]['admin_email'] =      ask("         admin_email: ") { |q| q.default = @settings_config[env]['admin_email'] }
      @settings_config[env]['admin_login'] =      ask("         admin_login: ") { |q| q.default = @settings_config[env]['admin_login'] }
      @settings_config[env]['admin_first_name'] = ask("    admin_first_name: ") { |q| q.default = @settings_config[env]['admin_first_name'] }
      @settings_config[env]['admin_last_name'] =  ask("     admin_last_name: ") { |q| q.default = @settings_config[env]['admin_last_name'] }

      # 
      # site_district and site_school
      #
      puts <<HEREDOC

The site district is a virtual district that contains the site school.
Any full member can become part of the site school and district.

HEREDOC
      @settings_config[env]['site_district']   =  ask("     site_district: ") { |q| q.default = @settings_config[env]['site_district'] }
      @settings_config[env]['site_school']     =  ask("       site_school: ") { |q| q.default = @settings_config[env]['site_school'] }
  
      # 
      # ---- states_and_provinces ----
      #
      get_states_and_provinces_settings(env)

      # 
      # ---- active_grades ----
      #
      get_active_grades_settings(env)

      # 
      # ---- valid_sakai_instances ----
      #
      get_active_school_levels(env)
      
      # 
      # ---- valid_sakai_instances ----
      #
      get_valid_sakai_instances(env)

      # 
      # ---- enable_default_users ----
      #
      puts <<HEREDOC

A number of default users are created that are good for testing but insecure for 
production deployments. Setting this value to true will enable the default users
setting it to false will disable the default_users for this envioronment.

HEREDOC
      default_users = @settings_config[env]['enable_default_users'].to_s
      default_users = ask("  enable_default_users: ", ['true', 'false']) { |q| q.default = default_users }
      @settings_config[env]['enable_default_users'] = eval(default_users)

      # 
      # ---- maven_jnlp ----
      #
      get_maven_jnlp_settings(env)

    end

    puts <<HEREDOC

Here are the updated application settings:
#{@settings_config.to_yaml} 
HEREDOC
  
    if agree("OK to save to config/settings.yml? (y/n): ")
      File.open(@settings_config_path, 'w') {|f| f.write @settings_config.to_yaml }
    end
  end
end

#
# update config/mailer.yml
#
def update_config_mailer_yml
  @mailer_config = YAML::load(IO.read(@mailer_config_path))

  delivery_types = [:test, :smtp, :sendmail]
  deliv_types = delivery_types.collect { |deliv| deliv.to_s }.join(' | ')

  authentication_types = [:plain, :login, :cram_md5]
  auth_types = authentication_types.collect { |auth| auth.to_s }.join(' | ')

  puts <<HEREDOC

----------------------------------------

Updating the Rails mailer configuration file: config/mailer.yml

You will need to specify values for the SMTP mail server this #{APPLICATION} instance will
use to send outgoing mail. In addition you need to specify the hostname of this specific 
#{APPLICATION} instance.

The SMTP parameters are used to send user account activation emails to new users and the 
hostname of the #{APPLICATION} is used as part of account activation url rendered into the 
body of the email.

You will need to specify a mail delivery method: (#{deliv_types})

  the hostname of the #{APPLICATION} without the protocol: (example: #{@mailer_config[:host]})

If you do not have a working SMTP server select the test deliver method instead of the 
smtp delivery method. The activivation emails will appear in #{@dev_log_path}. You can 
easily see then as the are generated with this command:

  tail -f -n 100 #{@dev_log_path}

You will also need to specify:

  the hostname of the #{APPLICATION} application without the protocol: (example: #{@mailer_config[:host]})

and a series of SMTP server values:

  host name of the remote mail server: (example: #{@mailer_config[:smtp][:address]}))
  port the SMTP server runs on (most run on port 25)
  SMTP helo domain
  authentication method for sending mail: (#{auth_types})
  username (only applies to the :login and :cram-md5 athentication methods)
  password (only applies to the :login and :cram-md5 athentication methods)

Here are the current settings in config/mailer.yml:

#{@mailer_config.to_yaml} 
HEREDOC
  unless agree("Accept defaults? (y/n) ")

    say("\nChoose mail delivery type: #{deliv_types}:\n\n")

    @mailer_config[:delivery_type] =            ask("    delivery type: ", delivery_types) { |q|
      q.default = "test"
    }

    @mailer_config[:host] =                     ask("    #{APPLICATION} hostname: ") { |q| q.default = @mailer_config[:host] }

    @mailer_config[:smtp][:address] =           ask("    SMTP address: ") { |q| 
      q.default = @mailer_config[:smtp][:address]
    }

    @mailer_config[:smtp][:port] =              ask("    SMTP port: ", Integer) { |q| 
      q.default = @mailer_config[:smtp][:port]
      q.in = 25..65535 
    }

    @mailer_config[:smtp][:domain] =            ask("    SMTP domain: ") { |q| 
      q.default = @mailer_config[:smtp][:domain]
    }

    say("\nChoose SMTP authentication type: #{auth_types}:\n\n")

    @mailer_config[:smtp][:authentication] =    ask("    SMTP auth type: ", authentication_types) { |q|
      q.default = "login"
    }

    @mailer_config[:smtp][:user_name] =         ask("    SMTP username: ") { |q| 
      q.default = @mailer_config[:smtp][:user_name]
    }

    @mailer_config[:smtp][:password] =          ask("    SMTP password: ") { |q| 
      q.default = @mailer_config[:smtp][:password]
    }

    puts <<HEREDOC

Here is the new mailer configuration:
#{@mailer_config.to_yaml} 
HEREDOC

    if agree("OK to save to config/mailer.yml? (y/n): ")
      File.open(@mailer_config_path, 'w') {|f| f.write @mailer_config.to_yaml }
    end
  end
end

# *****************************************************

puts <<HEREDOC

This setup program will help you configure a new #{APPLICATION} instance.

HEREDOC
check_for_git_submodules
check_for_config_database_yml
check_for_config_settings_yml
check_for_config_rinet_data_yml
check_for_config_mailer_yml
check_for_log_development_log
check_for_config_initializers_site_keys_rb
update_config_database_yml
update_config_settings_yml
update_config_rinet_data_yml
update_config_mailer_yml

puts <<HEREDOC

To complete setup of the RITES Investigations Rails application setup: 

  MRI Ruby:
    rake gems:install
    RAILS_ENV=production rake db:migrate:reset
    RAILS_ENV=production rake rigse:setup:new_rites_app
    
  JRuby:
    jruby -S rake gems:install
    RAILS_ENV=production jruby -S rake db:migrate:reset
    RAILS_ENV=production jruby -S rake rigse:setup:new_rites_app

These scripts will take about 5-30 minutes to run and are much faster if you are both running
Rails in production mode and using JRuby. If you are using separate databases for development and 
production and want to run these tasks to populate a development database I recommend temporarily 
identifying the development database as production for the purpose of generating these data.

HEREDOC