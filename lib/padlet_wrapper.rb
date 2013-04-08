class PadletWrapper

  DefaultHost  = 'padlet.com'
  DefaultEmail = 'all-portal-errors@concord.org'
  WallPath     = 'walls'
  AuthPath     = 'session'
  PolicyPath   = 'privacy_policies'
  PadletPublicPolicy = 4

  attr_accessor :password
  attr_accessor :username
  attr_accessor :padlet_url
  attr_accessor :padlet_user_id
  attr_accessor :auth_data
  attr_accessor :auth_cookies
  attr_accessor :policy_id
  attr_accessor :is_public
  attr_accessor :is_moderated

  yaml_file_path = File.join(Rails.root,'config','padlet.yml')
  Opts = {
    :host            => DefaultHost,
    :email           => DefaultEmail
  }

  begin
    yaml_config = YAML.load_file(yaml_file_path).symbolize_keys
    Opts.merge!(yaml_config)
  rescue Exception => e
    puts "Error: #{e} loading yaml: #{yaml_file_path}"
    puts "Using defaults (see padlet_wrapper.rb)"
  end

  def self.hostname
    Opts[:host]
  end

  def self.basic_auth_user
    Opts[:basic_auth_user]
  end

  def self.basic_auth_pass
    Opts[:basic_auth_pass]
  end

  def self.email
    Opts[:email]
  end

  def self.pass
    self.email.reverse
  end

  def self.make_bookmark(user=nil,pass=nil)
    user ||= self.email
    pass ||= self.pass
    instance = self.new(user,pass)
    instance.get_auth_token
    instance.make_wall
    return instance
  end

  def initialize(_user,_pass)
    self.username = _user
    self.password = _pass
  end

  def headers(opts)
    headers  = {'Content-Type' => 'application/json' }
    unless (self.auth_cookies.blank?)
      headers['cookie'] = self.auth_cookies.join(";")
    end
    opts[:headers] = headers
    opts
  end

  def get_opts(data)
    opts = {}
    headers(opts)
    auth_headers(opts)
    opts[:body] = data.to_json
    opts
  end

  def get_auth_token
    results = self.json_post(AuthPath, self.auth_request)
    cookies = results.get_fields('Set-Cookie');
    cookies.map! { |c|
      name, remainder = c.split("=",2)
      value = remainder.split(";")[0]
      "#{name}=#{value}"
    }
    results = JSON.parse(results)
    self.padlet_user_id = results['id']
    self.auth_data = results.dup
    self.auth_cookies   = cookies
    self
  end

  def make_wall
    results = self.json_post(WallPath,self.auth_data)
    self.padlet_url=results['links']['doodle'] # also checkout 'embed'
    self.fix_hostname_in_response_url
    # Noah removed because IE can't deal with basic auth urls:
    # http://support.microsoft.com/kb/834489
    # self.add_auth_info_to_url
    self
  end

  protected
  def auth_headers(opts)
    user =PadletWrapper.basic_auth_user
    pass =PadletWrapper.basic_auth_pass
    if (user && pass)
      opts[:basic_auth] = {:username => user, :password => pass }
    end
    opts
  end

  def auth_request
    {
      'email'    => self.username,
      'password' => self.password
    }
  end

  def format_request(path)
    return "http://#{PadletWrapper.hostname}/#{path}"
  end

  def json_get(path,data)
    endpoint = format_request(path)
    HTTParty.post(endpoint, self.get_opts(data))
  end

  def json_post(path,data)
    endpoint = format_request(path)
    args = self.get_opts(data)
    HTTParty.post(endpoint, args)
  end

  def json_put(path,data)
    endpoint = format_request(path)
    args = self.get_opts(data)
    HTTParty.put(endpoint, args)
  end

  # TODO: HACK/FIX the walls endpoint returns "stage.padlet.com"
  def fix_hostname_in_response_url
    self.padlet_url.gsub!(/.*padlet\.com/, "http://#{PadletWrapper.hostname}")
  end

  def add_auth_info_to_url
    user =PadletWrapper.basic_auth_user
    pass =PadletWrapper.basic_auth_pass
    host =PadletWrapper.hostname
    if (user && pass && host)
      replacement = "#{user}:#{pass}@#{host}"
      self.padlet_url.gsub!(PadletWrapper.hostname,replacement)
    end
  end

end
