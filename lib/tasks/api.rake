namespace :api do
  desc "Create API admin user with a client entry and token grant for 10 years"
  task :create_admin_user => :environment do

    # create the user if needed
    password = rand(36**16).to_s(36)
    api_user = User.find_or_create_by_login(
      :login                 => "admin_api_user",
      :first_name            => "Admin API",
      :last_name             => "User",
      :email                 => "admin_api_user@concord.org",
      :password              => password,
      :password_confirmation => password){|u| u.skip_notifications = true}
    api_user.confirm!
    api_user.add_role("admin")

    # create the client if needed
    client = Client.find_or_create_by_name(
      :name                  => "admin_api_user_client",
      :app_id                => "admin_api_user_client",
      :app_secret            => SecureRandom.uuid
    )

    # create the access token
    access_grant = api_user.access_grants.create({:client => client, :state => nil}, :without_protection => true)
    access_grant.update_attributes(:access_token_expires_at => Time.now + 10.year)

    puts "Access token: #{access_grant.access_token} (valid until #{access_grant.access_token_expires_at})"
  end
end
