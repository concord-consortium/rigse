namespace :sso do
  require 'highline/import'
  desc "add a new single signon client"
  task :add_client => :environment do
    client_id = ask("client_id: ") { |s| s.default = "localhost"       }
    secret = ask("secret: ")       { |s| s.default = SecureRandom.uuid }
    Client.create(:name => client_id, :app_id => client_id, :app_secret => secret)
  end
end
