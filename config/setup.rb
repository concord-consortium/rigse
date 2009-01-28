require 'rubygems'
require 'fileutils'
require 'yaml'
require 'erb'

# We require the uuidtools gem -- make sure it's available.
begin
  require 'uuidtools'
rescue Gem::LoadError 
  Please "install the uuidtools gem and run setup again: sudo gem install uuidtools"
end

RAILS_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
APP_DIR_NAME = File.basename(RAILS_ROOT)
$LOAD_PATH << File.join(%W{#{RAILS_ROOT} vendor gems highline-1.4.0 lib})

require 'highline.rb'
require 'highline/import.rb'

def copy_file(source, destination)

  puts <<HEREDOC
  copying: #{source}
       to: #{destination}

HEREDOC

  FileUtils.cp(source, destination)

end

def rails_file_path(*args)
  File.join([RAILS_ROOT] + args)
end


def rails_file_exists?(*args)
  File.exists?(rails_file_path(args))
end

puts <<HEREDOC

This setup program will help you configure a new RI-GSE instance.

HEREDOC

#
# check for config/database.yml
#

db_config_path = rails_file_path(%w{config database.yml})

unless File.exists?(db_config_path)
  puts <<HEREDOC

The Rails database configuration file does not yet exist.

HEREDOC

  db_config = YAML::load(IO.read(rails_file_path(%w{config database.mysql.sample.yml})))
  new_db_name = APP_DIR_NAME.gsub(/\W/, '_')

  %w{development test staging production}.each do |env|
    db_config[env]['database'] = "#{new_db_name}_#{env}"
  end

  puts <<HEREDOC
       creating: #{RAILS_ROOT}/config/database.yml
  from template: #{RAILS_ROOT}/config/database.sample.mysql.yml

HEREDOC
  
  File.open(db_config_path, 'w') {|f| f.write db_config.to_yaml }

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

site_key = UUID.timestamp_create().to_s

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

Specify values for the mysql database name, username and password
for the Rails database configuration file.
HEREDOC

db_config = YAML::load(IO.read(db_config_path))

%w{development test production}.each do |env|
  puts "\nSetting parameters for the #{env} database:\n\n"
  db_config[env]['database'] = ask("  database name: ") { |q| q.default = db_config[env]['database'] }
  db_config[env]['username'] = ask("       username: ") { |q| q.default = db_config[env]['username'] }
  db_config[env]['password'] = ask("       password: ") { |q| q.default = db_config[env]['password'] }
end

puts <<HEREDOC

Here is the updated database configuration:
#{db_config.to_yaml} 
HEREDOC
  
if agree("OK to save to config/database.yml? (y/n): ")
  File.open(db_config_path, 'w') {|f| f.write db_config.to_yaml }
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

You will need to specify values for the SMTP mail server this RI-GSE instance will
use to send outgoing mail. In addition you need to specify the hostname of this
specific RI-GSE instance.

The SMTP parameters are used to send user account activation emails to new 
users and the hostname of the RI-GSE is used as part of account activation url
rendered into the body of the email.

You will need to specify a mail delivery method: (#{deliv_types})

  the hostname of the RI-GSE without the protocol: (example: #{mailer_config[:host]})

If you do not have a working SMTP server select the test deliver method
instead of the smtp delivery method. The activivation emails will appear 
in #{dev_log_path}. You can easily see then as the are generated with this 
command:

  tail -f -n 100 #{dev_log_path}

You will also need to specify:

  the hostname of the RI-GSE without the protocol: (example: #{mailer_config[:host]})

and a series of SMTP server values:

  host name of the remote mail server: (example: #{mailer_config[:smtp][:address]}))
  port the SMTP server runs on (most run on port 25)
  SMTP helo domain
  authentication method for sending mail: (#{auth_types})
  username (only applies to the :login and :cram-md5 athentication methods)
  password (only applies to the :login and :cram-md5 athentication methods)

HEREDOC

say("\nChoose mail delivery type: #{deliv_types}:\n\n")

mailer_config[:delivery_type] =            ask("   delivery type: ", delivery_types) { |q|
  q.default = "test"
}

mailer_config[:host] =                     ask("    RI-GSE hostname: ") { |q| q.default = mailer_config[:host] }

mailer_config[:smtp][:address] =           ask("    SMTP address: ") { |q| 
  q.default = mailer_config[:smtp][:address]
}

mailer_config[:smtp][:port] =              ask("       SMTP port: ", Integer) { |q| 
  q.default = mailer_config[:smtp][:port]
  q.in = 25..65535 
}

mailer_config[:smtp][:domain] =            ask("     SMTP domain: ") { |q| 
  q.default = mailer_config[:smtp][:domain]
}

say("\nChoose SMTP authentication type: #{auth_types}:\n\n")

mailer_config[:smtp][:authentication] =    ask("  SMTP auth type: ", authentication_types) { |q|
  q.default = "login"
}

mailer_config[:smtp][:user_name] =        ask("   SMTP username: ") { |q| 
  q.default = mailer_config[:smtp][:user_name]
}

mailer_config[:smtp][:password] =         ask("   SMTP password: ") { |q| 
  q.default = mailer_config[:smtp][:password]
}

puts <<HEREDOC

Here is the new mailer configuration:
#{mailer_config.to_yaml} 
HEREDOC

if agree("OK to save to config/mailer.yml? (y/n): ")
  File.open(mailer_config_path, 'w') {|f| f.write mailer_config.to_yaml }
end

puts "\nTo complete the RI-GSE Rails application setup run:\n\n  rake rigse:setup:new_rigse_from_scratch\n\n"
