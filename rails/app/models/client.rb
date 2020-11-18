class Client < ActiveRecord::Base
  has_many :access_grants, :dependent => :delete_all

  PUBLIC = "public"
  CONFIDENTIAL = "confidential"
  TYPES = [PUBLIC, CONFIDENTIAL]

  def self.authenticate(app_id, app_secret)
    where(["app_id = ? AND app_secret = ?", app_id, app_secret]).first
  end

  def valid_from_referer?(referer)
    return true unless enforce_referrer?
    domain_matchers.split(/\s+/).each do |matcher|
      return true if (/^https?:\/\/#{matcher}/ =~ referer)
    end
    return false
  end

  def enforce_referrer?
    if domain_matchers.blank?
      false
    else
      true
    end
  end

  def updated_grant_for(user, time_to_live)
    grant = find_grant_for_user(user) || create_grant_for_user(user)
    grant.update_attribute(:access_token_expires_at, Time.now + time_to_live)
    grant
  end

  def check_redirect_uri(redirect_uri, extra_error_msg = "")
    unless redirect_uris && redirect_uris.split(" ").include?(redirect_uri)
      # Wrong redirect URI, we should NOT redirect back to the client.
      raise "Unauthorized redirect_uri: #{redirect_uri}. #{extra_error_msg}"
    end

    uri = URI.parse(redirect_uri)
    if uri.fragment
      # Note that redirect_uri is not allowed to include any fragment / hash params.
      # Wrong redirect URI, we should NOT redirect back to the client.
      raise "redirect_uri must not include fragment. #{extra_error_msg}"
    end

    # LARA still needs to run in http because of some interactives and activities
    # that were authored using http.  So we can't enforce https yet.
    # Uncomment this once LARA is fully moved to https
    # If this is uncommented then the test in client_spec.rb needs to be uncommented too
    #
    # if URI.parse(APP_CONFIG[:site_url]).scheme == "https" && uri.scheme != "https"
    #   # Enforce HTTPS when Portal is using HTTPS too.
    #   # # Wrong redirect URI, we should NOT redirect back to the client.
    #   raise "redirect_uri must use HTTPS protocol. #{extra_error_msg}"
    # end
  end

  def get_redirect_uri(redirect_uri, query_params = nil, hash_params = nil)

    check_redirect_uri(redirect_uri, "Requested query_params: #{query_params}, hash_params: #{hash_params}")

    uri = URI.parse(redirect_uri)
    if query_params
      query = Rack::Utils.parse_query(uri.query)
      query.merge!(query_params)
      uri.query = query.to_query
    end
    if hash_params
      # No fragment is allowed (see checks above), so we don't have to handle existing hash params.
      uri.fragment = URI.encode_www_form(hash_params)
    end
    uri.to_s
  end

  private
  def find_grant_for_user(user)
    access_grants.where({user_id: user.id, client_id:self.id}).first
  end

  def create_grant_for_user(user)
    user.access_grants.create(client_id:self.id, user_id:user.id)
  end
end
