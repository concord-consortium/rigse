class API::V1::ReportUserPolicy < Struct.new(:user, :api_v1_report_user)
  attr_reader :user, :request, :params, :api_v1_report_user

  def initialize(context, api_v1_report_user)
    @user = context.user
    @request = context.request
    @params = context.params
    @api_v1_report_user = api_v1_report_user
  end

  def index?
    manager_or_researcher_or_project_researcher?
  end

  def external_report_query?
    manager_or_researcher_or_project_researcher?
  end
end

private

def manager_or_researcher_or_project_researcher?
  user && (user.is_project_researcher? || user.is_project_admin? || user.has_role?('manager','admin','researcher'))
end
