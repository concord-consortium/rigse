require 'spec_helper'

# D10 KNOWN GAP (accepted, deferred): a marked (service-minted) token can still be converted into a
# Rails session, after which no marker exists and D9 propagation, the jwt_controller denial, and the
# D11 rules are all inert. jwt_bearer_token_authenticatable calls success!(user) with no store?
# override and skip_session_storage covers only :http_auth, so Warden serializes the user into the
# session. Skipped until the separate D10 story (store? false, after a consumer audit) lands.
RSpec.describe 'D10 known gap: marked token -> Rails session', type: :request do
  it 'must not establish a session from a marked token' do
    skip 'Blocked on the D10 portal-JWT session-storage story (store? false after a consumer audit). ' \
         'Until then a marked token still establishes a session and drops the marker. Un-skip when it lands.'
  end
end
