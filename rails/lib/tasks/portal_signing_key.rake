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
    puts "Public key, under kid #{kid}. Once the two values above are configured here,"
    puts 'portal_signing_key:public prints the entry report-server and the report-service'
    puts 'function are configured with, which also names the issuer this key is trusted for:'
    puts key.public_key.to_pem
  end

  desc 'Print this environment\'s PORTAL_PUBLIC_KEYS entry, which report-server and the report-service function verify with'
  task public: :environment do
    abort 'PORTAL_SIGNING_KEY and PORTAL_SIGNING_KEY_ID are not both set' unless PortalSigningKey.configured?
    puts 'PORTAL_PUBLIC_KEYS entry for this environment. It joins the JSON array report-server'
    puts "and the report-service function are configured with, beside every other portal's entry:"
    puts JSON.generate(
      kid: PortalSigningKey.kid,
      # The site URL exactly as this portal signs it into iss, trailing slash and all: both
      # verifiers trust a key only for its own issuer and compare the claim as a string.
      iss: APP_CONFIG[:site_url],
      pem: PortalSigningKey.private_key.public_key.to_pem
    )
  end
end
