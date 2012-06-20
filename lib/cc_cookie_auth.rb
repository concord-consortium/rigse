require 'digest/sha1'
module CCCookieAuth
  extend self
  
  def self.cookie_name
    'cc_auth_token'
  end
  ## token_separator
  def self.token_separator
    "||"
  end

  def max_age
    return 12.days.ago
  end

  def expired?(integer)
    return integer < max_age.to_i
  end

  # TODO: This is pretty week, beause the shared key remains constent for each client.
  # Instead we should create and store new(random) symetric one-time key for
  # each client, expiring it after some time, ala kerberoses KDC.
  def self.key_for(client)
    return Digest::SHA1.hexdigest("#{secret}#{client}")
  end

  def self.secret
    RailsPortal::Application.config.secret_token
  end

  def self.sign(payload,key)
    return Digest::SHA1.hexdigest("#{key}#{payload}")
  end

  ## save cookie in format such as login||remote_host||timestamp||sig
  ## args: login, remote_host
  def self.make_auth_token(login,remote_host)
    time = Time.now.to_i
    key = key_for(remote_host)
    data = [login, remote_host, time].join(token_separator)
    signature = sign(data,key)
    cookie = "#{data}#{token_separator}#{signature}"
    return cookie
  end
  
  def self.verify_auth_token(cookie,remote_host)
    return false if (cookie.nil? || cookie.empty?)
    login,host,time,signature = cookie.split(token_separator)
    # TODO: Check format of other fields.
    [login,host,time,signature].each do |item|
      return false if item.nil?
      return false if item.empty?
    end
    # because we are proxying hosts, we must ignore this
    # return false if (remote_host != host) 
    return false if expired?(time.to_i)
    key = key_for(host)
    data = [login,host,time].join(token_separator)
    check = sign(data,key)
    return (check == signature)
  end

end
