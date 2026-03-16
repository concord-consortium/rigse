class API::V1::EmailsController < API::APIController

  skip_before_action :verify_authenticity_token
  before_action :require_api_user!
  before_action :require_oidc_auth!

  # POST /api/v1/emails/oidc_send
  def oidc_send
    authorize [:api, :v1, :email], :oidc_send?

    subject = params.require(:subject)
    message = params.require(:message)

    unless subject.is_a?(String) && message.is_a?(String)
      return error('subject and message must be strings', 422)
    end

    # Validate recipient email exists
    unless current_user.email.present?
      return error('Your account has no email address configured', 422)
    end

    # Strip newlines from subject as header injection safeguard
    sanitized_subject = subject.gsub(/[\r\n]/, ' ')

    begin
      OidcMailer.send_message(current_user.email, sanitized_subject, message).deliver_now
    rescue StandardError => e
      Rails.logger.error(
        "OidcEmail: delivery failed to=#{current_user.email} " \
        "client=#{request.env['portal.auth_client']} error=#{e.class}: #{e.message}"
      )
      return error("Email delivery failed: #{e.class}: #{e.message}", 502)
    end

    Rails.logger.info(
      "OidcEmail: sent to=#{current_user.email} " \
      "subject=#{sanitized_subject.truncate(80)} " \
      "client=#{request.env['portal.auth_client']}"
    )

    render :json => { :success => true, :message => 'Email sent' }, :status => :ok
  end

  private

  def require_oidc_auth!
    unless request.env['portal.auth_strategy'] == 'oidc_bearer_token'
      return error('This endpoint requires OIDC authentication', 403)
    end
  end
end
