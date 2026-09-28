namespace :portal_signing_key do
  # Run once per environment; staging and production must never share the output.
  #   rake portal_signing_key:generate KID=production-2026-09
  desc 'Generate an RS256 keypair for PORTAL_SIGNING_KEY'
  task :generate do
    require 'openssl'
    kid = ENV.fetch('KID') { abort 'Set KID, e.g. KID=staging-2026-09' }
    key = OpenSSL::PKey::RSA.generate(2048)
    puts "PORTAL_SIGNING_KEY_ID=#{kid}"
    puts "PORTAL_SIGNING_KEY=#{key.to_pem.gsub("\n", '\n')}"
    puts
    puts "Public key for report-server and the report-service function, under kid #{kid}:"
    puts key.public_key.to_pem
  end

  desc 'Print the configured public key and kid, which report-server and the report-service function verify with'
  task public: :environment do
    abort 'PORTAL_SIGNING_KEY and PORTAL_SIGNING_KEY_ID are not both set' unless PortalSigningKey.configured?
    puts "kid: #{PortalSigningKey.kid}"
    puts PortalSigningKey.private_key.public_key.to_pem
  end
end
