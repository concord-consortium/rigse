require 'rubygems'
require 'fileutils'
require 'yaml'
require 'erb'

APPLICATION = "'RITES Investigations'"
puts "\nInitial setup of #{APPLICATION} Rails application ...\n"

JRUBY = defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'
RAILS_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
APP_DIR_NAME = File.basename(RAILS_ROOT)

def jruby_system_command
  JRUBY ? "jruby -S" : ""
end

def gem_install_command_strings(missing_gems)
  # jruby -S gem install uuidtools -v1.0.5 uuidtools -v1.0.6
  missing_gems.collect {|g| "#{g[0]} -v'#{g[1]}'"}.collect do |gem_name_and_version|
    if JRUBY
      "  jruby -S gem install #{gem_name_and_version}\n"
    else
      "  sudo gem install #{gem_name_and_version}\n"
    end
  end
end

def rails_file_path(*args)
  File.join([RAILS_ROOT] + args)
end

def rails_file_exists?(*args)
  File.exists?(rails_file_path(args))
end

@db_config_path = rails_file_path(%w{config database.yml})
@settings_config_path = rails_file_path(%w{config settings.yml})

@new_database_yml_created = false
@new_settings_yml_created = false

def copy_file(source, destination)

  puts <<HEREDOC
  copying: #{source}
       to: #{destination}

HEREDOC
  FileUtils.cp(source, destination)
end

@missing_gems = []
@gems_needed_at_start = [
  ['uuidtools', '>= 2.0.0'],
  ['highline', '>= 1.5.0'],
  ['haml-edge', '>= 2.1.8'],
  ['mime-types', '>=1.16'],
  ['diff-lcs', '>= 1.1.2'],
  ['prawn', '>= 0.4.1'],
  ['prawn-format', '>= 0.1.1']
]

if JRUBY 
  @gems_needed_at_start << ['activerecord-jdbcmysql-adapter', '>= 0.9.1']
  @gems_needed_at_start << ['jruby-openssl', '>=0.5']
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

# Continuing after sucessfully requiring the necessary gems ..

require 'highline/import'

# returns true if @db_name_prefix on entry == @db_name_prefix on exit
# false otherwise
def confirm_database_name_prefix
  original_db_name_prefix = @db_name_prefix
  puts <<HEREDOC

The default prefix for specifying the database names will be: #{@db_name_prefix}.

You can specify a different prefix for the database names:

HEREDOC
  @db_name_prefix = ask("  database name prefix: ") { |q| q.default = @db_name_prefix }
  @db_name_prefix == original_db_name_prefix
end

def create_new_database_yml
  raise "the instance variable @db_name_prefix must be set before calling create_new_database_yml" unless @db_name_prefix
  @db_config = YAML::load(IO.read(rails_file_path(%w{config database.mysql.sample.yml})))
  %w{development test staging production}.each do |env|
    @db_config[env]['database'] = "#{@db_name_prefix}_#{env}"
  end
  puts <<HEREDOC

       creating: #{RAILS_ROOT}/config/database.yml
  from template: #{RAILS_ROOT}/config/database.sample.mysql.yml

  using database name prefix: #{@db_name_prefix}

HEREDOC
  File.open(@db_config_path, 'w') {|f| f.write @db_config.to_yaml }
end

def create_new_settings_yml
  @settings_config = YAML::load(IO.read(rails_file_path(%w{config settings.sample.yml})))
  puts <<HEREDOC

       creating: #{RAILS_ROOT}/config/settings.yml
  from template: #{RAILS_ROOT}/config/settings.sample.mysql.yml
x}

HEREDOC
  File.open(@settings_config_path, 'w') {|f| f.write @settings_config.to_yaml }
end

puts <<HEREDOC

This setup program will help you configure a new #{APPLICATION} instance.

HEREDOC

#
# check for config/database.yml
#

unless File.exists?(@db_config_path)
  puts <<HEREDOC

The Rails database configuration file does not yet exist.

HEREDOC
  @db_name_prefix = APP_DIR_NAME.gsub(/\W/, '_')
  confirm_database_name_prefix
  create_new_database_yml
  @new_database_yml_created = true
end

#
# check for config/settings.yml
#

unless File.exists?(@settings_config_path)
  puts <<HEREDOC

The Rails application settings file does not yet exist.

HEREDOC
  create_new_settings_yml
  @new_settings_yml_created = true
end

#
# check for config/mailer.rb
#

mailer_config_path = rails_file_path(%w{config mailer.yml})

unless File.exists?(mailer_config_path)
  puts <<HEREDOC

The Rails mailer configuration file does not yet exist.

HEREDOC
  copy_file(rails_file_path(%w{config mailer.sample.yml}), mailer_config_path)
end

#
# check for log/development.log
#

dev_log_path = rails_file_path(%w{log development.log})

unless File.exists?(dev_log_path)
  puts <<HEREDOC

The Rails development log: 

  #{dev_log_path} does not yet exist.

  #{dev_log_path} created and permission set to 666

HEREDOC

  FileUtils.mkdir(rails_file_path("log")) unless File.exists?(rails_file_path("log"))
  FileUtils.touch(dev_log_path)
  FileUtils.chmod(0666, dev_log_path)

end

#
# check for config/initializers/site_keys.rb
#

site_keys_path = rails_file_path(%w{config initializers site_keys.rb})

unless File.exists?(site_keys_path)
  puts <<HEREDOC

The Rails site keys authentication tokens file does not yet exist: 

  #{site_keys_path} created.

HEREDOC

site_key = UUIDTools::UUID.timestamp_create.to_s

  site_keys_rb = <<HEREDOC
REST_AUTH_SITE_KEY         = '#{site_key}'
REST_AUTH_DIGEST_STRETCHES = 10
HEREDOC

  File.open(site_keys_path, 'w') {|f| f.write site_keys_rb }

end

#
# update config/database.yml
#

puts <<HEREDOC
----------------------------------------

Updating the Rails database configuration file: config/database.yml

Specify values for the mysql database name, username and password for the 
development staging and production environments.

HEREDOC

@db_config = YAML::load(IO.read(@db_config_path))

@db_name_prefix = @db_config['development']['database'][/(.*)_development/, 1]
create_new_database_yml unless @new_database_yml_created || confirm_database_name_prefix 

%w{development test production}.each do |env|
  puts "\nSetting parameters for the #{env} database:\n\n"
  @db_config[env]['database'] = ask("  database name: ") { |q| q.default = @db_config[env]['database'] }
  @db_config[env]['username'] = ask("       username: ") { |q| q.default = @db_config[env]['username'] }
  @db_config[env]['password'] = ask("       password: ") { |q| q.default = @db_config[env]['password'] }
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

puts <<HEREDOC

If you have access to a CCPortal database that indexes ITSI Activities into sequenced Units 
specify the values for the mysql database name, host, username, password.

HEREDOC

puts "\nSetting parameters for the CCPortal database:\n\n"
@db_config['ccportal']['database']  = ask("  database name: ") { |q| q.default = @db_config['ccportal']['database'] }
@db_config['ccportal']['host']      = ask("           host: ") { |q| q.default = @db_config['ccportal']['host']  }
@db_config['ccportal']['username']  = ask("       username: ") { |q| q.default = @db_config['ccportal']['username'] }
@db_config['ccportal']['password']  = ask("       password: ") { |q| q.default = @db_config['ccportal']['password'] }

puts <<HEREDOC

Here is the updated database configuration:
#{@db_config.to_yaml} 
HEREDOC
  
if agree("OK to save to config/database.yml? (y/n): ")
  File.open(@db_config_path, 'w') {|f| f.write @db_config.to_yaml }
end

#
# update config/settings.yml
#

puts <<HEREDOC
----------------------------------------

Updating the Rails database configuration file: config/settings.yml

Specify general application settings values: site url, site name, and admin name, email, login
for the development staging and production environments.

If you are doing development locally you may want to use one database for development and production.
Some of the importing scripts run much faster in production mode.

HEREDOC

@settings_config = YAML::load(IO.read(@settings_config_path))

%w{development staging production}.each do |env|
  puts "\n#{env}:\n"
  @settings_config[env]['site_url'] =         ask("          site url: ") { |q| q.default = @settings_config[env]['site_url'] }
  @settings_config[env]['site_name'] =        ask("         site_name: ") { |q| q.default = @settings_config[env]['site_name'] }
  @settings_config[env]['admin_email'] =      ask("       admin_email: ") { |q| q.default = @settings_config[env]['admin_email'] }
  @settings_config[env]['admin_login'] =      ask("       admin_login: ") { |q| q.default = @settings_config[env]['admin_login'] }
  @settings_config[env]['admin_first_name'] = ask("  admin_first_name: ") { |q| q.default = @settings_config[env]['admin_first_name'] }
  @settings_config[env]['admin_first_name'] = ask("  admin_first_name: ") { |q| q.default = @settings_config[env]['admin_first_name'] }
  puts "\n"
end

puts <<HEREDOC

Here are the updated application settings:
#{@settings_config.to_yaml} 
HEREDOC
  
if agree("OK to save to config/settings.yml? (y/n): ")
  File.open(@settings_config_path, 'w') {|f| f.write @settings_config.to_yaml }
end

#
# update config/mailer.yml
#

mailer_config = YAML::load(IO.read(mailer_config_path))

delivery_types = [:test, :smtp, :sendmail]
deliv_types = delivery_types.collect { |deliv| deliv.to_s }.join(' | ')

authentication_types = [:plain, :login, :cram_md5]
auth_types = authentication_types.collect { |auth| auth.to_s }.join(' | ')

puts <<HEREDOC

----------------------------------------

Updating the Rails mailer configuration file: config/mailer.yml

You will need to specify values for the SMTP mail server this #{APPLICATION} instance will
use to send outgoing mail. In addition you need to specify the hostname of this
specific #{APPLICATION} instance.

The SMTP parameters are used to send user account activation emails to new 
users and the hostname of the #{APPLICATION} is used as part of account activation url
rendered into the body of the email.

You will need to specify a mail delivery method: (#{deliv_types})

  the hostname of the #{APPLICATION} without the protocol: (example: #{mailer_config[:host]})

If you do not have a working SMTP server select the test deliver method
instead of the smtp delivery method. The activivation emails will appear 
in #{dev_log_path}. You can easily see then as the are generated with this 
command:

  tail -f -n 100 #{dev_log_path}

You will also need to specify:

  the hostname of the #{APPLICATION} application without the protocol: (example: #{mailer_config[:host]})

and a series of SMTP server values:

  host name of the remote mail server: (example: #{mailer_config[:smtp][:address]}))
  port the SMTP server runs on (most run on port 25)
  SMTP helo domain
  authentication method for sending mail: (#{auth_types})
  username (only applies to the :login and :cram-md5 athentication methods)
  password (only applies to the :login and :cram-md5 athentication methods)

HEREDOC

say("\nChoose mail delivery type: #{deliv_types}:\n\n")

mailer_config[:delivery_type] =            ask("    delivery type: ", delivery_types) { |q|
  q.default = "test"
}

mailer_config[:host] =                     ask("    #{APPLICATION} hostname: ") { |q| q.default = mailer_config[:host] }

mailer_config[:smtp][:address] =           ask("    SMTP address: ") { |q| 
  q.default = mailer_config[:smtp][:address]
}

mailer_config[:smtp][:port] =              ask("    SMTP port: ", Integer) { |q| 
  q.default = mailer_config[:smtp][:port]
  q.in = 25..65535 
}

mailer_config[:smtp][:domain] =            ask("    SMTP domain: ") { |q| 
  q.default = mailer_config[:smtp][:domain]
}

say("\nChoose SMTP authentication type: #{auth_types}:\n\n")

mailer_config[:smtp][:authentication] =    ask("    SMTP auth type: ", authentication_types) { |q|
  q.default = "login"
}

mailer_config[:smtp][:user_name] =         ask("    SMTP username: ") { |q| 
  q.default = mailer_config[:smtp][:user_name]
}

mailer_config[:smtp][:password] =          ask("    SMTP password: ") { |q| 
  q.default = mailer_config[:smtp][:password]
}

puts <<HEREDOC

Here is the new mailer configuration:
#{mailer_config.to_yaml} 
HEREDOC

if agree("OK to save to config/mailer.yml? (y/n): ")
  File.open(mailer_config_path, 'w') {|f| f.write mailer_config.to_yaml }
end

puts <<HEREDOC

To complete setup of the RITES Investigations Rails application setup run:

  #{jruby_system_command} rake rigse:setup:new_rigse_from_scratch

HEREDOC
