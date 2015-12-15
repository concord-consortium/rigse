class API::V1::DataPolicy < Struct.new(:user, :api_v1_data)
  attr_reader :user, :request, :params, :api_v1_data

  def initialize(context, api_v1_data)
    @user = context.user
    @request = context.request
    @params = context.params
    @api_v1_data = api_v1_data
  end

  def student_answers?
    is_admin?
  end

  private

  def is_admin?
    user && user.has_role?("admin")
  end

end
