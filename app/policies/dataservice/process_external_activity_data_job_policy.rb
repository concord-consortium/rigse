class Dataservice::ProcessExternalActivityDataJobPolicy < ApplicationPolicy

  def create?
    learner = Portal::Learner.find(params[:id])
    admin_or_manager? || (user == learner.user) ||  request_is_peer?
  end

end
