class API::V1::ExternalActivityPolicy < Struct.new(:user, :api_v1_external_activity)
  attr_reader :user, :request, :params, :api_v1_external_activity

  def initialize(context, api_v1_external_activity)
    @user = context.user
    @request = context.request
    @params = context.params
    @api_v1_external_activity = api_v1_external_activity
  end

  def create?
    user && (user.is_project_admin? || user.is_project_researcher? || user.has_role?('manager','admin','researcher'))
  end

end
