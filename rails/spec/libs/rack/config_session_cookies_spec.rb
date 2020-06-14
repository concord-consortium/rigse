# require File.expand_path('../../../spec_helper', __FILE__)
require 'rack'
require 'active_support/core_ext/object/blank'  # needed for blank? check
require File.expand_path("../../../../lib/rack/config_session_cookies", __FILE__)

describe Rack::ConfigSessionCookies do
  before(:each) do
    @tester = Rack::ConfigSessionCookies.new(double("app", :call => nil))
    allow(@tester).to receive_messages(:session_key => "_fake_session_key")
  end
  
  it "should have a stubbed session_key" do
    expect(@tester.session_key).to eql("_fake_session_key")
  end
  
  def make_env(options)
    env = {}
    options = {:path => "blah.config"}.merge(options)
    env['PATH_INFO'] = options[:path]
    env['QUERY_STRING'] = options[:query] if options[:query]
    env['HTTP_COOKIE'] = options[:cookie] if options[:cookie]
    env
  end
  
  describe "setting the cookie from query strings" do
    describe "with the correct session parameter name" do
      it "should set the cookie for allowed paths" do
        %w[blah.jnlp blah.config blah.dynamic_otml].each do |path|
          session_param = "_fake_session_key=1234#{path}1234"
          env = make_env(:path => path, :query => session_param)
          @tester.call(env)
          expect(env['HTTP_COOKIE']).to eql(session_param)
        end
      end
      it "should not set cookies for disallowed paths" do
          %w[blah.html blah.css blah blah.jpg].each do |path|
          session_param = "_fake_session_key=1234#{path}1234"
          env = make_env(:path => path, :query => session_param)
          @tester.call(env)
          expect(env['HTTP_COOKIE']).not_to eql(session_param)
        end
      end
    end
  end

  it "should change the session in the cookie if there is a correct query string" do
    session_param = "_fake_session_key=1234"
    env = make_env(:query => session_param, :cookie => "_fake_session_key=5678")
    @tester.call(env)
    expect(env['HTTP_COOKIE']).to eql(session_param)    
  end

  it "should preserve other parts of the cookie" do
    new_session = "_fake_session_key=1234"
    old_session = "_fake_session_key=5678"
    cases = {
     "#{old_session};something_else=12334" => 
       "#{new_session};something_else=12334",
       
     "something_first=12334;#{old_session}" =>
       "something_first=12334;#{new_session}",
       
     "something_first=12334;#{old_session};something_else=12334" =>
       "something_first=12334;#{new_session};something_else=12334",
     
     "something_else=12334" =>
       "something_else=12334;#{new_session}",
      
    }
    
    cases.each{|key, value|
      env = make_env(:query => new_session, 
                     :cookie => String.new(key))
      @tester.call(env)
      expect(env['HTTP_COOKIE']).to eql(value)
    }
  end

  it "should not add other query params to the cookie" do
    session_param = "_fake_session_key=1234"
    [ "#{session_param}&param2=3",
      "param2=3&#{session_param}",
      "param2=3&#{session_param}&param3=5"
    ].each{|query|
        env = {}
        env['PATH_INFO'] = "blah.config"
        env['QUERY_STRING'] = query
        @tester.call(env)
        expect(env['HTTP_COOKIE']).to eql(session_param)
    }
  end

  it "should not change the environment if the path doesn't match" do
    env = {
      'PATH_INFO' => "blah",
    }
    original_hash = env.hash
    @tester.call(env)
    expect(env.hash).to equal(original_hash)
  end

  it "should not change the environment if there is no query string" do
    env = {}

    env['PATH_INFO'] = "blah.config"
    original_hash = env.hash
    @tester.call(env)
    expect(env.hash).to equal(original_hash)

    env['PATH_INFO']  = "blah.jnlp"
    original_hash = env.hash
    @tester.call(env)
    expect(env.hash).to equal(original_hash)
  end
  
  it "should not change the environment if there is a incorrect query string" do
    env = {}
    env['PATH_INFO'] = "blah.config"
    env['QUERY_STRING'] = "_wrong_session_key=1234"
    original_hash = env.hash
    @tester.call(env)
    expect(env.hash).to equal(original_hash)
    
    env = {}
    env['PATH_INFO'] = "blah.jnlp"
    env['QUERY_STRING'] = "_wrong_session_key=1234"
    original_hash = env.hash
    @tester.call(env)
    expect(env.hash).to equal(original_hash)
  end

end
