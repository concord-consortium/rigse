require 'spec_helper'

# Tripwire: D11 confinement (ApplicationController#confine_service_minted_tokens) does not run for
# mounted Rack engines. If you add a `mount`, decide how marked (service-minted) tokens are confined
# for it, then update this list.
RSpec.describe 'mounted Rack engines' do
  it 'has no unreviewed mounted engines' do
    mounts = File.readlines(Rails.root.join('config/routes.rb')).grep(/^\s*mount\s/)
    expect(mounts.size).to eq(1)
    expect(mounts.first).to match(%r{Delayed::Web::Engine.*/delayed_job})
  end
end
