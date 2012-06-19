require 'spec_helper'

describe CCCookieAuth do
  # helper to forge cookies
  def sign(opts)
    login     = opts[:login]     || 'anonymous'
    host      = opts[:host]      || '127.0.0.1'
    key       = opts[:key]       || CCCookieAuth.key_for(host)
    time      = opts[:time]      || Time.now.to_i
    sep       = opts[:token]     || CCCookieAuth.token_separator
    data      = opts[:data]      || [login,host,time].join(sep)
    signature = opts[:signature] || CCCookieAuth.sign(data,key)
    return signature
  end

  # helper to forge cookies
  def forge_cookie(opts)
    login     = opts[:login]     || 'anonymous'
    host      = opts[:host]      || '127.0.0.1'
    key       = opts[:key]       || CCCookieAuth.key_for(host)
    time      = opts[:time]      || Time.now.to_i
    sep       = opts[:token]     || CCCookieAuth.token_separator
    data      = opts[:data]      || [login,host,time].join(sep)
    signature = opts[:signature] || CCCookieAuth.sign(data,key)
    cookie = [login,host,time,signature].join(sep)
    return cookie
  end

  describe 'key_for(client)' do
    before(:each) do
      @client_a = "123.456.123.456"
      @client_b = "123.456.123.123"
    end
    describe 'for different clients' do
      it "should return the differing keys" do
        CCCookieAuth.key_for(@client_a).should_not == CCCookieAuth.key_for(@client_b)
      end
    end
    describe 'for the same clients' do
      it "should return the same keys" do
        CCCookieAuth.key_for(@client_a).should == CCCookieAuth.key_for(@client_a)
      end
    end
  end

  describe 'sign(payload,key)' do
    before(:each) do
      @payload_a = "this is the first message"
      @payload_b = "this is the second message"
      @key_a  = "first_key"
      @key_b  = "second_key"
    end

    describe 'given the same payload and key' do
      it 'should return the same signature' do
        CCCookieAuth.sign(@payload_a,@key_a).should == CCCookieAuth.sign(@payload_a,@key_a)
      end
    end
    describe 'given the same payloads, but differing keys' do
      it 'should return different signatures' do
        CCCookieAuth.sign(@payload_a,@key_a).should_not == CCCookieAuth.sign(@payload_a,@key_b)
      end
    end
    describe 'given different payloads, but the same keys' do
      it 'should return different signatures' do
        CCCookieAuth.sign(@payload_a,@key_a).should_not == CCCookieAuth.sign(@payload_b,@key_b)
      end
    end
  end

  describe 'make_auth_token(login,host)' do
    before(:each) do
      # user||host||time||sig
      @format_pattern = /(.*)\|\|(.*)\|\|(.*)\|\|([0-9a-f]{5,40})/
      @host = "127.0.0.1"
      @login = "knowuh" 
    end
    it 'should match the token format known format' do
      CCCookieAuth.make_auth_token(@login,@host).should match @format_pattern
    end
  end

  describe 'verify_auth_token(cookie,host)' do
    before(:each) do
      @login = "knowuh"
      @host  = "127.0.0.1"
    end
    describe 'a valid token' do
      before(:each) do
        @cookie = forge_cookie(:login => @login, :host => @host);
      end
      it 'should verify' do
        CCCookieAuth.verify_auth_token(@cookie,@host).should be true
      end
    end

    describe 'missmatched logins' do
      before(:each) do
        @time = Time.now.to_i
        opts = { :login => @login, :host => @host, :time => @time }
        @signature = sign(opts)
        @cookie = forge_cookie(opts.update(:login => 'bwob',:signature => @signature));
      end
      it 'should reject credentials' do
        CCCookieAuth.verify_auth_token(@cookie,@host).should be false
      end
    end
    
    describe 'missmatched hosts' do
      before(:each) do
        @time = Time.now.to_i
        opts = { :login => @login, :host => @host, :time => @time }
        @signature = sign(opts)
        @cookie = forge_cookie(opts.update(:host => 'google.com'));
      end
      it 'should reject credentials' 
        # pending: we can't do this through a proxy!
        #do
          #CCCookieAuth.verify_auth_token(@cookie,@host).should be false
        #end
    end
    describe 'bad signatures' do
      before(:each) do
        @time = Time.now.to_i
        opts = { :login => @login, :host => @host, :time => @time }
        @signature = sign(opts)
        @cookie = forge_cookie(opts.update(:signature => @signature.reverse));
      end
      it 'should reject credentials' do
        CCCookieAuth.verify_auth_token(@cookie,@host).should be false
      end
    end

    describe 'tokens that are too old' do
      before(:each) do
        @time = 14.days.ago.to_i
        @host = '127.0.0.1'
        @cookie = forge_cookie(:time => @time,:host => @host);
      end
      # TODO: there is currently no expiration
      it 'should reject credentials' do
        CCCookieAuth.verify_auth_token(@cookie,@host).should be false
      end
    end
  end
  
end
