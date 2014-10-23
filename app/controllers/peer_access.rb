module PeerAccess
  # TODO: we must always use SSL for peer to peer communication.
  # or we could encrypt a known string using the shared secret as salt.

  protected
  def get_auth_token(request)
    header = request.headers["Authorization"]
    if header && header =~ /^Bearer (.*)$/
      return $1
    end
    return ""
  end
  
  def verify_request_is_peer
    auth_token = get_auth_token(request)
    peer_tokens = Client.all.map { |c| c.app_secret }.uniq
    peer_tokens.include?(auth_token)
  end

end