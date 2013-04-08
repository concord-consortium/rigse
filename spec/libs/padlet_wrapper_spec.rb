require File.expand_path('../../spec_helper', __FILE__)

require 'fakeweb'

describe PadletWrapper do

  before(:each) do
    PadletWrapper.stub!(:host => "www.fakeo.com")
    PadletWrapper.stub!(:basic_auth_user => nil)
    PadletWrapper.stub!(:basic_auth_pass => nil)
    @padlet_user_id = rand(1000);
    @cookies = [
      "ww_d=cb9a7cf32981e79d34518d293a4760f6",
      "ww_p=BAh7B0kiD3Nlc3Npb25faWQGOgZFRkkiJTk4YmVhY2JlYzA5YjY0MGU4MGZlZjI4YWE4MThmMWE5BjsAVEkiDHVzZXJfaW"
    ]

    @auth_url = "http://#{PadletWrapper.hostname}/#{PadletWrapper::AuthPath}"
    @auth_url = "http://concordconsortium.padletpro.com/session"
    @auth_data = {
         "auth_type" => 1,
        "created_at" => "2013-02-27T16:54:42Z",
             "email" => "all-portal-errors@concord.org",
                "id" => @padlet_user_id,
        "identities" => {},
              "name" => nil,
        "short_name" => "all-portal-errors",
               "uid" => nil
    }.to_json

    @padlet_wall_url = "http://concordconsortium.padletpro.com/wall/86rrqfm6ut"
    @wall_data = {

               "address" => "86rrqfm6ut",
            "background" => {
              "url" => nil
          },
               "builder" => {
                  "id" => 5658987,
          "short_name" => "all-portal-errors"
        },
            "created_at" => "2013-02-27T16:54:42Z",
           "description" => "",
           "domain_name" => nil,
                    "id" => 1779492,
                 "links" => {
          "doodle" => @padlet_wall_url,
           "embed" => "http://concordconsortium.padletpro.com/embed/86rrqfm6ut",
            "feed" => "http://concordconsortium.padletpro.com/feed/86rrqfm6ut",
            "snap" => "http://concordconsortium.padletpro.com/snap/86rrqfm6ut"
        },
                "notify" => false,
              "portrait" => "",
        "privacy_policy" => {
                          "id" => 971713,
                   "is_listed" => false,
                "is_moderated" => false,
                    "owner_id" => 5658987,
          "password_protected" => false,
                      "public" => 2,
                       "users" => nil,
                     "wall_id" => 1779492
        },
            "public_key" => "86rrqfm6ut",
                 "title" => "",
            "updated_at" => "2013-04-05T18:18:58Z",
                   "viz" => "free"
    }.to_json


    @make_public_response = {
            "eusers" => nil,
                "id" => 972516,
         "is_listed" => false,
      "is_moderated" => false,
          "owner_id" => 5658987,
          "password" => nil,
            "public" => 4,
           "wall_id" => 1780279
    }.to_json

    @wall_url = "http://#{PadletWrapper.hostname}/#{PadletWrapper::WallPath}"
    @make_public_url = "http://#{PadletWrapper.hostname}/#{PadletWrapper::PolicyPath}/971713"

    FakeWeb.register_uri(:post, @auth_url,
      :status => ["200", "OK"],
      :content_type => "application/json",
      :body => @auth_data,
      :content => @auth_data,
      :set_cookie => @cookies.join("; ")
    )
    FakeWeb.register_uri(:post, @wall_url,
      :status => ["200", "OK"],
      :content_type => "application/json",
      :body => @wall_data,
      :content => @wall_data,
      :set_cookie => @cookies.join("; ")
    )

    FakeWeb.register_uri(:put, @make_public_url,
      :status => ["200", "OK"],
      :content_type => "application/json",
      :body => @make_public_response,
      :content => @make_public_response,
      :set_cookie => @cookies.join("; ")
    )

    @padlet = PadletWrapper.new('bub','pass')
  end


  describe "initialize(_user,_pass)" do
    it "should set the username and password" do
      @padlet.password.should == 'pass'
      @padlet.username.should == 'bub'
    end
  end

  describe "get_auth_token" do
    it "should return valid authentication info" do
      @padlet.get_auth_token
      @padlet.padlet_user_id.should == @padlet_user_id
    end
  end

  describe "self.make_wall(user=nil,pass=nil)" do
    it "should return valid url" do
      @padlet.get_auth_token
      @padlet.make_wall
    end
  end

  describe "self.make_public" do
    it "should be public after calling make_public" do
      @padlet.get_auth_token
      @padlet.make_wall
      @padlet.make_public
      @padlet.padlet_url.should == @padlet_wall_url
      @padlet.is_public.should be_true
    end
  end
  # describe "make_wall" do
  # end


  # describe "make_wall_public" do
  # end




  # TODO: Consider making these methods private:
  # def self.hostname
  # def self.basth_user
  # def self.basic_auth_pass
  # def self.email
  # def self.pass

  # def headers(opts)
  # def auth_headers(opts)
  # def get_opts(data)
  # def json_get(path,data)
  # def json_post(path,data)

end
