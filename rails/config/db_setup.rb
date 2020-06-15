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
rails_root = File.dirname(File.dirname(FULL_PATH))
puts "using rails_root = #{rails_root}"

# Mock just a bit of the Rails3 Rails object
Rails = OpenStruct.new( "root" => rails_root, "env" => RAILS_ENV)

@db_admin_username = 'root'
@db_admin_username = ask("  mysql admin user: ") { |q| q.default = "admin" }
@db_admin_pass = ask("  mysql admin password: ") { |q| q.default = "password" }
# LATER:  We might want to add remote DB hosts?


def rails_file_path(*args)
  File.join([Rails.root] + args)
end

def create_db(hash)  
  database = hash['database']
  username = hash['username']
  password = hash['password']
  
  # delete first:
  %x[ mysqladmin -f -u #{@db_admin_username} -p#{@db_admin_pass}  drop #{database} ]
  %x[ mysqladmin -f -u #{@db_admin_username} -p#{@db_admin_pass}  create #{database} ]
  
  @hosts.each do |h|
    %x[ mysql mysql -u #{@db_admin_username} -p#{@db_admin_pass} -e "grant all on #{database}.* to '#{username}'@'#{h}'  identified by '#{password}';" ]
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



