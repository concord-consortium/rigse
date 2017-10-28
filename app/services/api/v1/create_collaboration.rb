class API::V1::CreateCollaboration
  include ActiveModel::Validations
  include Virtus.model
  include RailsPortal::Application.routes.url_helpers

  # Input.
  attribute :offering_id, Integer
  attribute :students, Array[Hash]
  attribute :owner_id, Integer
  attribute :host_with_port, String
  attribute :protocol, String

  attr_reader :result

  # Instance of Portal::Collaboration generated after successful `call` execution.
  attr_reader :collaboration

  validate :owner_valid?
  validate :offering_valid?
  validate :students_valid?

  def call
    if valid? && persist!
      @result = json_result
    else
      false
    end
  end

  def owner_valid?
    return true if Portal::Student.exists?(self.owner_id)
    errors.add(:owner_id, "Collaboration can be created only by student")
    false
  end

  def students_valid?
    self.students.each_with_index do |s, idx|
      if !Portal::Student.exists?(s['id'])
        errors.add(:"students[#{idx}]", "Student does not exist")
        return false
      end
    end
    true
  end

  def offering_valid?
    return true if Portal::Offering.exists?(self.offering_id)
    errors.add(:offering_id, "Unknown offering ID")
    false
  end

  private

  def persist!
    persist_collaboration
  end

  def json_result
    collaborators_data_url = collaborators_data_api_v1_collaboration_url(self.collaboration,
                                                                         protocol: self.protocol,
                                                                         host:     self.host_with_port)
    result = {
      id: self.collaboration.id,
      collaborators_data_url: collaborators_data_url
    }
    if @offering.external_activity?
      # Prepare ready URL for client so it can simply redirect without constructing the final URL itself.
      external_activity_url = @offering.runnable.url
      # Domain is needed by LARA to authenticate correctly.
      external_activity_url = add_param(external_activity_url, 'domain', root_url(protocol: self.protocol,
                                                                                  host:     self.host_with_port))
      external_activity_url = add_param(external_activity_url, 'collaborators_data_url', collaborators_data_url)
      
      external_activity_url = add_param(external_activity_url, 'logging', @offering.clazz.logging)
      result[:external_activity_url] = external_activity_url
    end
    result
  end

  def persist_collaboration
    @owner           = Portal::Student.find(self.owner_id)
    @offering        = Portal::Offering.find(self.offering_id)
    @student_objects = self.students.map { |s| Portal::Student.find(s['id']) }
    # Make sure that owner is a collaborator, even if not provided in the list.
    @student_objects << @owner
    @student_objects = @student_objects.compact.uniq

    @collaboration = Portal::Collaboration.create!(
      :owner => @owner,
      :offering => @offering
    )
    @collaboration.students = @student_objects

    setup_learners
    setup_bundles unless @offering.external_activity?
    true
  end

  def setup_learners
    @owner_learner = @offering.find_or_create_learner(@owner)
    @learner_objects = @student_objects.map do |s|
      @offering.find_or_create_learner(s)
    end
  end

  # Only for JNLP activities.
  def setup_bundles
    bundle_logger = @owner_learner.bundle_logger
    bundle_logger.start_bundle
    # Clear any in_progress_bundles for any of the collaborators, except for the current student.
    learners_to_clear = @learner_objects - [@owner_learner]
    learners_to_clear.each do |l|
      if l.bundle_logger && l.bundle_logger.in_progress_bundle
        l.bundle_logger.end_bundle({:body => ""})
      end
    end
    # Set collaboration only in owner's bundle.
    bundle_logger.in_progress_bundle.collaboration = @collaboration
    bundle_logger.in_progress_bundle.save!
    # Displays message visible for student, which is later updated (see controllers/portal/offerings_controller.rb).
    setup_dataservice_event(bundle_logger.in_progress_bundle)
  end

  # Only for JNLP activities.
  def setup_dataservice_event(bundle)
    # This is used to display info for student and present progress of download and lunch process.
    Dataservice::LaunchProcessEvent.create!(
      :event_type => Dataservice::LaunchProcessEvent::TYPES[:session_started],
      :event_details => "Learner session started. Requesting activity launcher...",
      :bundle_content => bundle
    )
  end

  def password_valid?(student_hash)
    student_id = student_hash['id']
    password   = student_hash['password']
    user       = Portal::Student.find(student_id).user
    return true if User.authenticate(user.login, password)
    false
  end

  def add_param(url, param_name, param_value)
    uri = URI(url)
    params = URI.decode_www_form(uri.query || '') << [param_name, param_value]
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

end
