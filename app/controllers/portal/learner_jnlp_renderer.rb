module Portal::LearnerJnlpRenderer
  def render_learner_jnlp(learner)
    jnlp_session = Dataservice::JnlpSession.create!(:user => current_user)

    # only start a bundle if this really is the learner, this method is also used by teachers
    # who want run jnlps 
    if current_user == learner.student.user
      if(!learner.bundle_logger.in_progress_bundle)
        learner.bundle_logger.start_bundle
      end

      launch_event = Dataservice::LaunchProcessEvent.create(
        :event_type => Dataservice::LaunchProcessEvent::TYPES[:jnlp_requested],
        :event_details => "Activity launcher delivered. Activity should be opening...",
        :bundle_content => learner.bundle_logger.in_progress_bundle
      )
    end

    render :partial => 'shared/learn_or_installer', :locals => { 
      :skip_installer => params.delete(:skip_installer), 
      :runnable => learner.offering.runnable, 
      :learner => learner, :jnlp_session => jnlp_session.token }
  end
end