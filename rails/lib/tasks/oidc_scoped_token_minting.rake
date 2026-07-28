namespace :oidc do
  # Usage: rake oidc:enable_scoped_token_minting SUB=<google-sa-sub>
  task enable_scoped_token_minting: :environment do
    client = Admin::OidcClient.find_by!(sub: ENV.fetch('SUB'))
    client.update!(can_mint_scoped_tokens: true)
    puts "Enabled scoped-token minting for #{client.name} (id=#{client.id}); user_id=#{client.user_id}"
  end

  # Usage: rake oidc:disable_scoped_token_minting SUB=<google-sa-sub>
  task disable_scoped_token_minting: :environment do
    client = Admin::OidcClient.find_by!(sub: ENV.fetch('SUB'))
    client.update!(can_mint_scoped_tokens: false)
    puts "Disabled scoped-token minting for #{client.name} (id=#{client.id})"
  end
end
