module Portal::LearnerJnlpRenderer
  def render_learner_jnlp(learner)
    jnlp_session = Dataservice::JnlpSession.create!(:user => current_visitor)

    render :partial => 'shared/installer', :locals => {
      :runnable => learner.offering.runnable,
      :learner => learner, :jnlp_session => jnlp_session }
  end
end
