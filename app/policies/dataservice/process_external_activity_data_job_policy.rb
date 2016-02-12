class Dataservice::ProcessExternalActivityDataJobPolicy < ApplicationPolicy

  def create?
    learner = Portal::Learner.find_by_id_or_key(params[:id_or_key])
    admin_or_manager? || (user == learner.user) ||  request_is_peer?
  end

  def create_by_protocol_version?
    learner = Portal::Learner.find_by_id_or_key(params[:id_or_key])
    admin_or_manager? || (user == learner.user) ||  request_is_peer?
  end
end
