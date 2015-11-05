module Portal::LearnerJnlpRenderer
  def render_learner_jnlp(learner)
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Portal::LearnerJnlpRenderer.rb
    # authorize @learner_jnlp_renderer.rb
    # authorize Portal::LearnerJnlpRenderer.rb, :new_or_create?
    # authorize @learner_jnlp_renderer.rb, :update_edit_or_destroy?
    jnlp_session = Dataservice::JnlpSession.create!(:user => current_visitor)

    # only start a bundle if this really is the learner, this method is also used by teachers
    # who want run jnlps 
    if current_visitor == learner.student.user
      if(!learner.bundle_logger.in_progress_bundle)
        learner.bundle_logger.start_bundle
      end

      launch_event = Dataservice::LaunchProcessEvent.create(
        :event_type => Dataservice::LaunchProcessEvent::TYPES[:jnlp_requested],
        :event_details => "Activity launcher delivered. Activity should be opening...",
        :bundle_content => learner.bundle_logger.in_progress_bundle
      )
    end

    render :partial => 'shared/installer', :locals => {
      :runnable => learner.offering.runnable,
      :learner => learner, :jnlp_session => jnlp_session }
  end
end
