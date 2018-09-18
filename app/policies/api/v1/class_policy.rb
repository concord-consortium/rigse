class API::V1::ClassPolicy < Struct.new(:user, :api_v1_class)
  include API::V1::PunditSupport

  attr_reader :user, :request, :params, :api_v1_class

  def initialize(context, api_v1_class)
    @user = context.user
    @request = context.request
    @params = context.params
    @api_v1_class = api_v1_class
  end

  def show?
    unless user
      failed_to_log_in
    end

    unless user.teacher_or_student
      raise Pundit::NotAuthorizedError, 'You must be logged in as a student or teacher to use this endpoint'
    end

    true
  end

  alias_method :mine?, :show?

  def log_links?
    unless user
      failed_to_log_in
    end

    user.must_be_admin
  end
end
