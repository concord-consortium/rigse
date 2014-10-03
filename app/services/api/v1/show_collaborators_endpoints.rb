class API::V1::ShowCollaboratorsEndpoints
  include ActiveModel::Validations
  include Virtus.model
  include RailsPortal::Application.routes.url_helpers

  ACCESS_TOKEN_EXPIRE_TIME = 1.day

  # Input
  attribute :collaboration_id, Integer
  attribute :host_with_port, String

  # Output
  attr_reader :result

  def call
    @collaboration = Portal::Collaboration.find(self.collaboration_id)
    @result = json_result
  end

  private

  def json_result
    @collaboration.students.map do |s|
      learner = get_learner(s)
      {
        name: s.user.name,
        email: s.user.email,
        # Not sure why this is needed, but currently LARA expects that value
        # for regular activity run.
        learner_id: learner.id,
        # This URL can be used by external activity system to publish back
        # student answers.
        endpoint_url: external_activity_return_url(learner.id, host: self.host_with_port),
        # Access token shouldn't be shared at all. Make sure that access to this
        # service is very strict.
        access_token: s.user.create_access_token_valid_for(ACCESS_TOKEN_EXPIRE_TIME)
      }
    end
  end

  def get_learner(student)
    @collaboration.offering.find_or_create_learner(student)
  end

end
