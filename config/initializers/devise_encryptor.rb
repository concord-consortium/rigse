module Devise
  module Encryptable
    module Encryptors
      # Compatable with our old-old version of restful-authentication.
      # restful_authentication_sha1 included with devise couldn't
      # handle our version (1.1.1 July 2008)  --- NP 2013_03_28
      class OldRestfulAuthenticationSha1 < Base
        def self.digest(password, stretches, salt, pepper)
          # TODO: Documentation to indicate "pepper" isn't being used.
          # TODO: Create a migration from this old digest to something new.
          key = digest = REST_AUTH_SITE_KEY
          # From http://bit.ly/ZrHT22 & http://bit.ly/ZrHZ9K
          # (github links to our now non-existing restful-auth plugin)
          REST_AUTH_DIGEST_STRETCHES.times do
            args = [digest,salt,password,key]
            digest = Digest::SHA1.hexdigest(args.flatten.join('--'))
          end
          digest
        end
      end
    end
  end
end