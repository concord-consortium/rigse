class CustomFailure < Devise::FailureApp

  # Disable redirects (by redirecting to the current url) because of session timeouts.
  # Let the normal authentication rules force a redirect.
  def redirect
    store_location!
    message = warden.message || warden_options[:message]
    if message == :timeout
      redirect_to attempted_path
    else
      super
    end
  end

  def redirect_url
    #return super unless [:worker, :employer, :user].include?(scope) #make it specific to a scope
     #new_user_session_url(:subdomain => 'secure')
     if request.env['HTTP_REFERER']
       request.env['HTTP_REFERER']
     else
       root_path
     end
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
