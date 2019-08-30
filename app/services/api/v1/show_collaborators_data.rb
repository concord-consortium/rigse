class API::V1::ShowCollaboratorsData
  include ActiveModel::Validations
  include Virtus.model
  include RailsPortal::Application.routes.url_helpers

  # Input
  attribute :collaboration_id, Integer
  attribute :host_with_port, String
  attribute :protocol, String

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
        # Not sure why this is needed, but currently LARA expects that value for regular activity run.
        learner_id: learner.id,
        # This URL can be used by external activity system to publish back  student answers.
        endpoint_url: learner.remote_endpoint_url,
        # New LTI-like data necessary for LARA to create searchable entities in Firestore.
        platform_id: APP_CONFIG[:site_url],
        platform_user_id: s.user.id.to_s,
        resource_link_id: @collaboration.offering.id,
        context_id: @collaboration.offering.clazz.class_hash,
        class_info_url: @collaboration.offering.clazz.class_info_url(self.protocol, self.host_with_port)
      }
    end
  end

  def get_learner(student)
    @collaboration.offering.find_or_create_learner(student)
  end

end
