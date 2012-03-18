# require File.expand_path('../../../spec_helper', __FILE__)
require 'rack'
require File.expand_path("../../../../lib/rack/config_session_cookies", __FILE__)

describe Rack::ConfigSessionCookies do
  before(:each) do
    @tester = Rack::ConfigSessionCookies.new(double("app", :call => nil))
    @tester.stub(:session_key => "_fake_session_key")
  end
  
  it "should have a stubbed session_key" do
    @tester.session_key.should eql("_fake_session_key")
  end
  
  def make_env(options)
    env = {}
    options = {:path => "blah.config"}.merge(options)
    env['PATH_INFO'] = options[:path]
    env['QUERY_STRING'] = options[:query] if options[:query]
    env['HTTP_COOKIE'] = options[:cookie] if options[:cookie]
    env
  end
  
  it "should set the cookie if there is a correct query string" do
    session_param = "_fake_session_key=1234"
    env = make_env(:query => session_param)
    @tester.call(env)
    env['HTTP_COOKIE'].should eql(session_param)
    
    env = make_env(:path => "blah.jnlp", :query => session_param)
    @tester.call(env)
    env['HTTP_COOKIE'].should eql(session_param)
  end

  it "should change the session in the cookie if there is a correct query string" do
    session_param = "_fake_session_key=1234"
    env = make_env(:query => session_param, :cookie => "_fake_session_key=5678")
    @tester.call(env)
    env['HTTP_COOKIE'].should eql(session_param)    
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
      env['HTTP_COOKIE'].should eql(value)
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
        env['HTTP_COOKIE'].should eql(session_param)
    }
  end

  it "should not change the environment if the path doesn't match" do
    env = {
      'PATH_INFO' => "blah",
    }
    original_hash = env.hash
    @tester.call(env)
    env.hash.should equal(original_hash)
  end

  it "should not change the environment if there is no query string" do
    env = {}

    env['PATH_INFO'] = "blah.config"
    original_hash = env.hash
    @tester.call(env)
    env.hash.should equal(original_hash)

    env['PATH_INFO']  = "blah.jnlp"
    original_hash = env.hash
    @tester.call(env)
    env.hash.should equal(original_hash)
  end
  
  it "should not change the environment if there is a incorrect query string" do
    env = {}
    env['PATH_INFO'] = "blah.config"
    env['QUERY_STRING'] = "_wrong_session_key=1234"
    original_hash = env.hash
    @tester.call(env)
    env.hash.should equal(original_hash)
    
    env = {}
    env['PATH_INFO'] = "blah.jnlp"
    env['QUERY_STRING'] = "_wrong_session_key=1234"
    original_hash = env.hash
    @tester.call(env)
    env.hash.should equal(original_hash)
  end
end