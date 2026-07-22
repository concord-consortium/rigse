module ForwardedAuthGuard
  extend ActiveSupport::Concern

  private

  # Force the Warden chain (lazy current_user) so the OIDC strategy can stamp
  # portal.auth_error, then render the distinguishable 401 before Pundit runs.
  # A no-op for non-OIDC requests, which never stamp portal.auth_error.
  def reject_forwarded_auth_error
    current_user
    code = request.env['portal.auth_error']
    return unless code
    error(auth_error_message(code), 401, nil, code)
  end

  def auth_error_message(code)
    case code
    when 'forwarded_token_invalid'  then 'Forwarded student token is invalid'
    when 'forwarded_token_required' then 'A forwarded student token is required'
    when 'oidc_token_invalid'       then 'OIDC service token is invalid'
    else 'Authentication failed'
    end
  end
end
