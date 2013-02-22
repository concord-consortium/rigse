class PadletHelper

  PadletBaseUri = 'http://padlet.com'
  DefaultEmail = "all-portal-errors@concord.org"

  attr_accessor :password
  attr_accessor :username
  attr_accessor :padlet_url
  attr_accessor :padlet_user_id
  attr_accessor :auth_data
  attr_accessor :auth_cookies

  def self.email
    Admin::Project.settings_for(:help_email) || DefaultEmail
  end

  def self.pass
    self.email.reverse
  end

  def self.make_bookmark(user=nil,pass=nil)
    user ||= self.email
    pass || self.pass
    instance = self.new(user,pass)
    instance.get_auth_token
    instance.make_wall
    return instance
  end

  def initialize(_user,_pass)
    self.username = _user
    self.password = _pass
  end

  def make_data(data)
    headers  = {'Content-Type' => 'application/json' }
    unless (self.auth_cookies.blank?)
      headers['cookie'] = self.auth_cookies.join(";")
    end
    return {
      :headers =>  headers,
      :body    =>  data.to_json
    }
  end

  def json_get(path,data)
    endpoint = "#{PadletBaseUri}/#{path}"
    HTTParty.post(endpoint, self.make_data(data))
  end

  def json_post(path,data)
    endpoint = "#{PadletBaseUri}/#{path}"
    HTTParty.post(endpoint, self.make_data(data))
  end

  def get_auth_token
    results = self.json_post('/session', self.auth_request)
    self.padlet_user_id = results['id']
    self.auth_data = results.dup
    cookies = results.get_fields('Set-Cookie');
    cookies.map! { |c|
      name, remainder = c.split("=",2)
      value = remainder.split(";")[0]
      "#{name}=#{value}"
    }
    self.auth_cookies   = cookies
    self
  end

  def auth_request
    {
      'email'    => self.username,
      'password' => self.password
    }
  end

  def make_wall
    results = self.json_post('/walls',self.auth_data)
    # self.padlet_url=results['links']['embed']
    self.padlet_url=results['links']['doodle']
    self
  end

end
