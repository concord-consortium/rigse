require 'spec_helper'

RSpec.describe PortalSigningKey do
  def with_env(overrides)
    stub_const('ENV', ENV.to_h.merge(overrides))
  end

  describe ".configured?" do
    it "is true with both the key and its kid" do
      expect(PortalSigningKey.configured?).to be true
    end

    it "is false when the key is blank" do
      with_env('PORTAL_SIGNING_KEY' => '')
      expect(PortalSigningKey.configured?).to be false
    end

    it "is false when the kid is blank" do
      with_env('PORTAL_SIGNING_KEY_ID' => '')
      expect(PortalSigningKey.configured?).to be false
    end
  end

  describe ".private_key" do
    it "parses a PEM stored with literal \\n sequences" do
      pem = OpenSSL::PKey::RSA.generate(2048).to_pem
      with_env('PORTAL_SIGNING_KEY' => pem.gsub("\n", '\n'))
      expect(PortalSigningKey.private_key.to_pem).to eq(pem)
    end

    it "raises SignedJwt::Error for a malformed PEM" do
      with_env('PORTAL_SIGNING_KEY' => 'not a key')
      expect { PortalSigningKey.private_key }.to raise_error(SignedJwt::Error, /not a valid RSA key/)
    end
  end

  describe ".verification_key" do
    it "returns the current key's public half as a key object" do
      key = PortalSigningKey.verification_key('test-key')
      expect(key).to be_a(OpenSSL::PKey::RSA)
      expect(key.private?).to be false
      expect(key.to_pem).to eq(PortalSigningKey.private_key.public_key.to_pem)
    end

    it "raises for an unknown kid" do
      expect { PortalSigningKey.verification_key('nope') }.to raise_error(SignedJwt::Error, /Unrecognized/)
    end

    it "raises SignedJwt::Error for malformed PORTAL_PREVIOUS_VERIFY_KEYS JSON" do
      with_env('PORTAL_PREVIOUS_VERIFY_KEYS' => '{not json')
      expect { PortalSigningKey.verification_key('test-key') }.to raise_error(SignedJwt::Error, /not valid JSON/)
    end

    it "does not let a previous key replace the current one under the same kid" do
      other = OpenSSL::PKey::RSA.generate(2048)
      with_env('PORTAL_PREVIOUS_VERIFY_KEYS' => { 'test-key' => other.public_key.to_pem }.to_json)
      expect(PortalSigningKey.verification_key('test-key').to_pem).to eq(PortalSigningKey.private_key.public_key.to_pem)
    end
  end
end
