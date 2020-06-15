require 'spec_helper'

describe PadletWrapper do
  before do
    PadletWrapper::OPTS[:host] = "www.fakeo.com"
    PadletWrapper::OPTS[:basic_auth_user] = nil
    PadletWrapper::OPTS[:basic_auth_pass] = nil
  end

  let(:wall_url) { "http://concordconsortium.padletpro.com/wall/86rrqfm6ut" }
  let(:wall_policy_id) { 971713 }

  let(:padlet_auth_url) { "http://#{PadletWrapper::OPTS[:host]}/#{PadletWrapper::AUTH_PATH}" }
  let(:padlet_wall_url) { "http://#{PadletWrapper::OPTS[:host]}/#{PadletWrapper::WALL_PATH}" }
  let(:padlet_policy_url) { "http://#{PadletWrapper::OPTS[:host]}/#{PadletWrapper::POLICY_PATH}/#{wall_policy_id}" }

  let(:make_wall_response) do
    # Of course real response is much bigger, but we care only about these properties.
    {
      "links" => {
        "doodle" => wall_url
      },
      "privacy_policy" => {
        "id" => wall_policy_id
      }
    }
  end
  let(:make_public_response) do
    # See above.
    {
      "public" => 4
    }
  end

  describe 'when communication with Padlet website works as expected' do
    before do
      stub_request(:post, padlet_auth_url).
        to_return(status: 201)

      stub_request(:post, padlet_wall_url).
        to_return(status: 201,
          headers: {'Content-Type' => "application/json"},
          body: make_wall_response.to_json
          )

      stub_request(:put, padlet_policy_url).
        to_return(status: 200,
          headers: {'Content-Type' => "application/json"},
          body: make_public_response.to_json
          )
    end

    it 'should create new Padlet and provide its URL' do
      expect(PadletWrapper.new.padlet_url).to eql(wall_url)
    end
  end

  describe 'when communication with Padlet website is broken (e.g. due to Padlet API change)' do
    before do
      stub_request(:post, padlet_auth_url).
        to_return(status: 201)

      stub_request(:post, padlet_wall_url).
        to_return(status: 400)
    end

    it 'should raise an error' do
      expect { PadletWrapper.new }.to raise_error(JSON::ParserError)
    end
  end
end
