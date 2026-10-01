require 'spec_helper'

RSpec.describe 'config.filter_parameters' do
  let(:filter) { ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters) }

  it 'keeps OAuth and token credentials out of the logs' do
    filtered = filter.filter(
      'client_secret' => 's3cret', 'code' => 'abc', 'code_verifier' => 'v' * 43,
      'access_token' => 'at', 'refresh_token' => 'rt', 'token' => 't', 'firebase_token' => 'ft',
      'password' => 'pw'
    )
    expect(filtered.values.uniq).to eq(['[FILTERED]'])
  end

  it "keeps a client's secret out of the admin form's logs" do
    expect(filter.filter('client' => { 'app_secret' => 's3cret', 'name' => 'LARA' }))
      .to eq('client' => { 'app_secret' => '[FILTERED]', 'name' => 'LARA' })
  end

  it 'leaves the parameters that identify a request readable' do
    kept = { 'client_id' => 'lara', 'redirect_uri' => 'https://lara.example.org/cb', 'grant_type' => 'authorization_code',
             'code_challenge_method' => 'S256', 'zipcode' => '01742', 'state' => 'st' }
    expect(filter.filter(kept)).to eq(kept)
  end

  it "logs the implicit flow's redirect, whose fragment carries a token, as [FILTERED]" do
    request = ActionDispatch::TestRequest.create('action_dispatch.redirect_filter' => Rails.application.config.filter_redirect)
    response = ActionDispatch::Response.new
    response.request = request
    response.location = 'https://client.example.org/cb#access_token=abc&token_type=bearer&state=st'
    expect(response.filtered_location).to eq('[FILTERED]')
    response.location = 'https://client.example.org/cb?code=abc&state=st'
    expect(response.filtered_location).to eq('https://client.example.org/cb?code=[FILTERED]&state=st')
  end
end
