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
    lara_domain = ENV['LARA_DOMAIN'].blank? ? 'app.lara.docker' : ENV['LARA_DOMAIN']
    Client.where(name: 'authoring').first_or_create(
        :name       => 'authoring',
        :app_id     => 'authoring',
        :app_secret => 'unsecure local secret',
        :site_url   => "https://#{lara_domain}",
        :client_type => 'confidential',
        :redirect_uris => "https://#{lara_domain}/users/auth/cc_portal_localhost/callback"
    )
  end

end
