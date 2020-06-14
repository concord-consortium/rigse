class API::V1::AnswerPolicy < Struct.new(:user, :api_v1_answer)
  attr_reader :user, :request, :params, :api_v1_answer

  def initialize(context, api_v1_answer)
    @user = context.user
    @request = context.request
    @params = context.params
    @api_v1_answer = api_v1_answer
  end

  def student_answers?
    is_admin?
  end

  private

  def is_admin?
    user && user.has_role?("admin")
  end

end
