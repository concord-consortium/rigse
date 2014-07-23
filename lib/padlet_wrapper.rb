class PadletWrapper
  attr_reader :padlet_url

  DEFAULT_HOST = 'padlet.com'

  AUTH_PATH = 'session'
  WALL_PATH = 'walls'
  POLICY_PATH = 'privacy_policies'
  PADLET_PUBLIC_POLICY = 4

  OPTS = {
    :host => DEFAULT_HOST
  }
  begin
    yaml_file_path = File.join(Rails.root, 'config', 'padlet.yml')
    yaml_config = YAML.load_file(yaml_file_path).symbolize_keys
    OPTS.merge!(yaml_config)
  rescue Exception => e
    puts "Error: #{e} loading yaml: #{yaml_file_path}"
    puts "Using defaults (see padlet_wrapper.rb)"
  end

  def initialize
    @cookies = []
    @policy_id = nil
    authenticate # optional!
    make_wall
    make_public
  end

  private

  def authenticate
    # Note it's optional step. If Padlet credentials are
    # not provided then wall will belong to anonymous user.
    padlet_user = OPTS[:padlet_user]
    padlet_pass = OPTS[:padlet_pass]
    if padlet_user && padlet_pass
      # Each request updates cookies. That's enough for authentication.
      req(:post, AUTH_PATH, {
        'email'    => padlet_user,
        'password' => padlet_pass
      })
    end
  end

  def make_wall
    response = req(:post, WALL_PATH, {})
    body = JSON.parse(response.body)
    @padlet_url = body['links']['doodle']
    @policy_id  = body['privacy_policy']['id']
    # TODO verify response
  end

  def make_public
    # We need to be authenticated to perform this step.
    # Note that even if we didn't authenticate explicitly (no Padlet credentials provided),
    # wall creation caused that we have cookies set and are authenticated as 'Anonymous',
    # actual owner of Padlet wall.
    req(:put, "#{POLICY_PATH}/#{@policy_id}", {
      'id'     => @policy_id,
      'public' => PADLET_PUBLIC_POLICY
    })
    # TODO verify response
  end

  def req(method, path, data)
    endpoint = "http://#{OPTS[:host]}/#{path}"
    opts = get_httparty_opts(data)
    response = case method
               when :get
                 HTTParty.get(endpoint, opts)
               when :post
                 HTTParty.post(endpoint, opts)
               when :put
                 HTTParty.put(endpoint, opts)
               end
    save_cookies(response)
    response
  end

  def save_cookies(response)
    @cookies = response.get_fields('Set-Cookie').map! { |c|
      name, remainder = c.split("=", 2)
      value = remainder.split(";")[0]
      "#{name}=#{value}"
    }
  end

  def get_httparty_opts(data)
    {
      headers: get_headers,
      basic_auth: get_basic_auth,
      body: data.to_json
    }
  end

  def get_headers
    {
      'Content-Type' => 'application/json',
      'Cookie'       => @cookies.join(';')
    }
  end

  def get_basic_auth
    user = OPTS[:basic_auth_user]
    pass = OPTS[:basic_auth_pass]
    return { username: user, password: pass } if user && pass
    return nil
  end
end
