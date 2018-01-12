namespace :sso do
  require 'highline/import'

  desc "add a new single signon client"
  task :add_client => :environment do
    client_id = ask("client_id: ") { |s| s.default = "localhost"       }
    secret = ask("secret: ")       { |s| s.default = SecureRandom.uuid }
    site_url = ask("site_url: ")       { |s| s.default = "http://localhost.com" }
    Client.create(:name => client_id, :app_id => client_id, :app_secret => secret, :site_url => site_url)
  end

  desc "add a new single signon dev test client"
  task :add_dev_client => :environment do
    Client.create(
        :name       => 'localhost',
        :app_id     => 'localhost',
        :app_secret => 'unsecure local secret',
        :site_url   => 'http://localhost.com'
    )
  end

end
