class API::V1::CollaborationPolicy < Struct.new(:user, :api_v1_collaboration)
  attr_reader :user, :request, :params, :api_v1_collaboration

  def initialize(context, api_v1_collaboration)
    @user = context.user
    @request = context.request
    @params = context.params
    @api_v1_collaboration = api_v1_collaboration
  end

  def create?
    is_class_member?
  end

  def available_collaborators?
    is_class_member?
  end

  def collaborators_data?
    request_is_peer?
  end

  private

  def is_class_member?
    return false if !user || !user.portal_student
    offering = Portal::Offering.find_by_id(params[:offering_id])
    offering && offering.clazz.students.include?(user.portal_student)
  end

  def request_is_peer?
    auth_header = request.headers["Authorization"]
    auth_token = auth_header && auth_header =~ /^Bearer (.*)$/ ? $1 : ""
    peer_tokens = Client.all.map { |c| c.app_secret }.uniq
    peer_tokens.include?(auth_token)
  end

end
