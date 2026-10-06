require 'spec_helper'

# The token endpoints accept POST only, so a code, secret or verifier never travels in a URL.
RSpec.describe 'OAuth token routes', type: :routing do
  %w[/oauth/token /auth/concord_id/access_token].each do |path|
    it "routes POST #{path} to auth#access_token and not GET" do
      expect(post: path).to route_to('auth#access_token')
      expect(get: path).not_to be_routable
    end
  end
end
