class API::V1::EmailPolicy < Struct.new(:user, :api_v1_email)
  attr_reader :user, :request, :params, :api_v1_email

  def initialize(context, api_v1_email)
    @user = context.user
    @request = context.request
    @params = context.params
    @api_v1_email = api_v1_email
  end

  def oidc_send?
    user && request.env['portal.auth_strategy'] == 'oidc_bearer_token'
  end
end
