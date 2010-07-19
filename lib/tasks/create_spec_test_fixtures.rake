namespace :app do
  namespace :test do

    def instance_to_fixture(object, name_attr)
      result =''
      result << object.send(name_attr) + ":\n"
      object.attributes.each do |attr|
        result << sprintf("%-30s%-0s", "  #{attr[0]}:", " #{attr[1]}\n")
      end
      result << "\n"
    end

    desc "Saves users.yaml to spec/fixtures" 
    task :create_fixtures => :environment do 
      dir = File.join(RAILS_ROOT, 'spec/fixtures')
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir) do
        File.open("users.yml", 'w') do |f|
          quentin = User.new(:login => 'quentin', :email => 'quentin@example.com', :password => "monkey", :password_confirmation => "monkey")
          quentin.encrypt_password
          aaron   = User.new(:login => 'aaron', :email => 'aaron@example.com', :password => "monkey", :password_confirmation => "monkey")
          aaron.encrypt_password
          users_yaml = <<-HEREDOC

quentin:
  id:                        1
  vendor_interface_id:       1
  uuid:                      7aef8f84-627b-11de-97fe-001ff3caa767
  login:                     quentin
  email:                     quentin@example.com
  salt:                      #{quentin.salt}
  crypted_password:          #{quentin.crypted_password}
  created_at:                <%= 5.days.ago.to_s :db  %>
  remember_token_expires_at: <%= 1.days.from_now.to_s %>
  remember_token:            77de68daecd823babbb58edb1c8e14d7106e83bb
  activation_code:           
  activated_at:              <%= 5.days.ago.to_s :db %>
  state:                     active

aaron:
  id:                        2
  uuid:                      8ddb615e-627b-11de-97fe-001ff3caa767
  vendor_interface_id:       1
  login:                     aaron
  email:                     aaron@example.com
  salt:                      #{aaron.salt}
  crypted_password:          #{aaron.crypted_password}
  created_at:                <%= 1.days.ago.to_s :db %>
  remember_token_expires_at: 
  remember_token:            
  activation_code:           1b6453892473a467d07372d45eb05abc2031647a
  activated_at:              
  state:                     pending


old_password_holder:
  id:                        3
  uuid:                      95edf87a-627b-11de-97fe-001ff3caa767
  vendor_interface_id:       1
  login:                     old_password_holder
  email:                     salty_dog@example.com
  salt:                      7e3041ebc2fc05a40c60028e2c4901a81035d3cd
  crypted_password:          00742970dc9e6319f8019fd54864d3ea740f04b1 # test
  created_at:                <%= 1.days.ago.to_s :db %>
  activation_code:           
  activated_at:              <%= 5.days.ago.to_s :db %>
  state:                     active

          HEREDOC
          f.write users_yaml
        end
      end
    end

  end
end
