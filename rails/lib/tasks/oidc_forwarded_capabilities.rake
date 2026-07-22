namespace :oidc do
  # Usage: rake oidc:grant_forwarded_capabilities SUB=<google-sa-sub>
  task grant_forwarded_capabilities: :environment do
    client = Admin::OidcClient.find_by!(sub: ENV.fetch('SUB'))
    granted = (client.capabilities || []) | %w[enroll_student update_offering_state send_teacher_email]
    client.update!(capabilities: granted)
    puts "Granted capabilities to #{client.name} (id=#{client.id}); capabilities=#{client.capabilities.inspect} user_id=#{client.user_id} requires_forwarded_jwt=#{client.requires_forwarded_jwt}"
  end

  # Usage: rake oidc:verify_forwarded_capabilities SUB=<google-sa-sub>
  task verify_forwarded_capabilities: :environment do
    client = Admin::OidcClient.find_by!(sub: ENV.fetch('SUB'))
    required = %w[enroll_student update_offering_state send_teacher_email]
    missing = required - (client.capabilities || [])
    if missing.any?
      abort "FAIL: #{client.name} (id=#{client.id}) is missing capabilities #{missing.inspect}; grant them before enabling REPORT-83 forwarding."
    end
    puts "OK: #{client.name} (id=#{client.id}) holds all required forwarded-student capabilities."
  end

  # Usage: rake oidc:require_forwarded_jwt SUB=<google-sa-sub>
  task require_forwarded_jwt: :environment do
    client = Admin::OidcClient.find_by!(sub: ENV.fetch('SUB'))
    client.update!(requires_forwarded_jwt: true, user_id: nil)
    puts "Flipped #{client.name} (id=#{client.id}) to require forwarded JWT; user_id now nil"
  end
end
