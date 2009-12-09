require 'rubygems'
require 'fileutils'
require 'yaml'
require 'erb'
require 'socket'
require 'highline/import'

@hosts = ['localhost','127.0.0.1']
@hosts << IPSocket.getaddress(Socket.gethostname)
@hosts << Socket.gethostname
puts "using db localhosts: #{@hosts.join(', ')}"

FULL_PATH = File.expand_path(__FILE__)
RAILS_ROOT = File.dirname(File.dirname(FULL_PATH))
puts "using RAILS_ROOT = #{RAILS_ROOT}"


@db_admin_username = 'root'
@db_admin_username = ask("  mysql admin user: ") { |q| q.default = "admin" }
@db_admin_pass = ask("  mysql admin password: ") { |q| q.default = "password" }
# LATER:  We might want to add remote DB hosts?


def rails_file_path(*args)
  File.join([RAILS_ROOT] + args)
end

def create_db(hash)  
  database = hash['database']
  username = hash['username']
  password = hash['password']
  
  # delete first:
  %x[ mysqladmin -f -u #{@db_admin_username} -p#{@db_admin_pass}  drop #{database} ]
  %x[ mysqladmin -f -u #{@db_admin_username} -p#{@db_admin_pass}  create #{database} ]
  
  @hosts.each do |h|
    
    # puts %Q[ mysql mysql -u #{@db_admin_username} -p#{@db_admin_pass} -e "drop user '#{username}'@'#{h}';" ]
    # %x[ mysql mysql -u #{@db_admin_username} -p#{@db_admin_pass} -e "drop user '#{username}'@'#{h}';" ]
    
    puts %Q[ mysql mysql -u #{@db_admin_username} -p#{@db_admin_pass} -e "create user '#{username}'@'#{h}' identified by '#{password}';" ]
    %x[ mysql mysql -u #{@db_admin_username} -p#{@db_admin_pass} -e "create user '#{username}'@'#{h}' identified by '#{password}';" ]
    
    puts %Q[mysql mysql -u #{@db_admin_username} -p#{@db_admin_pass} -e "grant all privileges on #{database}.* to '#{username}'@'#{h}' with grant option;" ]
    %x[ mysql mysql -u #{@db_admin_username} -p#{@db_admin_pass} -e "grant all privileges on #{database}.* to '#{username}'@'#{h}' with grant option;" ]
  end
end


db_config_path = rails_file_path(%w{config database.yml})
if File.exists?(db_config_path)
  @db_config = YAML::load_file(db_config_path)
  @db_config.each do |c| 
    puts c.class
    puts c.inspect
    if c[1]
      puts c[1].class
      create_db c[1]
    end
  end
else
  puts " couldn't find the database config file: #{db_config_path}"
end



