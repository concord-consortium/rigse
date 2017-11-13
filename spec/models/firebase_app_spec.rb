require File.expand_path('../../spec_helper', __FILE__)

describe FirebaseApp do
  before(:each) do
    @valid_app_name = "test app"
    @valid_client_email = "user@example.com"
    @valid_attributes = {
      :name => @valid_app_name,
      :client_email => @valid_client_email,
      # note: the private key below is just a random key - it is not used anywhere
      :private_key => "-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCAZxhEvNE6IY6vMfpC2mmWfnnfU7wCG/Hraui5a/OPKkxPnOHL
Iq8UljEHVuD+NXChtJwovVPHw8Jv1IQKFTWNi9GZ+wtbZaRezH2cuDvodpQv9Hlg
ddCN6s9jQMMpnSLPRRmP5MuTvXgHg6o754Zyzb46lnyTY0ToIapG4HKbywIDAQAB
AoGAF6TkTyQF0xKC17f4QX8+mjvH7VvZ7vl+Xr9dA2fhfadoTfCxk1pbqwrNFHDn
FWh5yQ0dBFN4rfxaPYWAmuq05Ywky9AQj5eS4T50kZKLuElzh9vo6ZH7dgx3NlMs
eCgiHG3GuDI9WFHBB/LMgatufwBnRt8cTVev7X+BAjznFuECQQDS2w1HW+1xaOrQ
3/5v56BNeyfqVeUdLnTc8ndVhQi9nDNv5FSNa7nBwd6YXEvwvr0INe8FlB5AVZiE
udNWb/zlAkEAm+TQ/WoHBmxPjYYHWUW2RjTAGLeEnlwtwny5d0ZfkP04eROA5mct
6+Z9WduL1t8/V0K7RCJRPnwkGIQkgDla7wJACTsHsMkIcv+J0A0OQW3daabrj2ml
NwrSmN2QddD2Gf7djZdsUCiYIDBRg0//DxH6ioJ57T+Xt29H1v+fjdgnNQJAKMwe
AWPBCOZJf3EG9U7wH7loWE+WrlbTRuWbJ+LL2cbbA5yeDC4Ob4D3Zw+0rfvouK5n
EbKlbmPQknXqk3/vEwJBAJR2p1ZOoMWevrnLpodqExH/PPABkb8mRvx1j5bNwHzT
nC64AqP02IP2yOxnbxZ1uY2TrdI1VcO3AwcngxSEUMo=
-----END RSA PRIVATE KEY-----"
    }
  end
  let(:user) { FactoryGirl.create(:user) }

  it "should create a new instance given valid attributes" do
    FirebaseApp.create!(@valid_attributes)
  end

  it "should be valid when used in a signed JWT" do
    FirebaseApp.create!(@valid_attributes)
    token = SignedJWT::create_firebase_token(user, @valid_app_name)
    decoded_token = SignedJWT::decode_firebase_token(token, @valid_app_name)
    decoded_token[:data]["uid"].should eql user.id
    decoded_token[:data]["iss"].should eql @valid_client_email
    decoded_token[:data]["sub"].should eql @valid_client_email
    decoded_token[:data]["aud"].should eql "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit"
  end

  it "should throw an error in a signed JWT when it doesn't exist" do
    expect { SignedJWT::create_firebase_token(user, @valid_app_name) }.to raise_error(SignedJWT::Error)
  end

  it "should create a valid JWT with claims" do
    FirebaseApp.create!(@valid_attributes)
    claims = {foo: "bar"}
    token = SignedJWT::create_firebase_token(user, @valid_app_name, 3600, claims)
    decoded_token = SignedJWT::decode_firebase_token(token, @valid_app_name)
    decoded_token[:data]["foo"].should eql "bar"
  end

  it "should throw an error when create a JWT with claims if reserved keys are used" do
    FirebaseApp.create!(@valid_attributes)
    claims = {sub: "bar"}
    expect { SignedJWT::create_firebase_token(user, @valid_app_name, 3600, claims) }.to raise_error(SignedJWT::Error)
  end

end
