class API::V1::Report
  include RailsPortal::Application.routes.url_helpers
  REPORT_VERSION = "1.0.3"

  def initialize(options)
    # offering, protocol, host_with_port, student_ids = nil, activity_id=nil)
    @offering          = options[:offering]
    @protocol          = options[:protocol]
    @host_with_port    = options[:host_with_port]
    @activity_id       = options[:activity_id]
    @hide_controls     = options[:hide_controls]
    @activity_id       = options[:activity_id]
    student_ids        = options[:student_ids]
    @report_for = 'class'

    if student_ids
      @students = Portal::Student.where(id: student_ids).includes([:user, :clazzes])
      @students = @students.select { |s| s.clazz_ids.include?  @offering.clazz_id }
      @report_for = 'student'
    else
      @students =  @offering.clazz.students.includes(:user)
      @report_for = 'class'
    end
  end

  def is_teacher?(user)
    @offering.clazz.teachers.include?(user.portal_teacher)
  end

  def is_student?(user)
    user.portal_student && @offering.clazz.students.include?(user.portal_student)
  end

  def is_report_for_student?(user)
    is_student?(user)  && @students.length == 1 && @students.first == user.portal_student
  end

  def to_json
    clazz = class_json
    answers_hash = get_student_answers
    provide_no_answer_entries(answers_hash, clazz[:students])
    {
        report: report_json(answers_hash),
        report_version: REPORT_VERSION,
        report_for: @report_for,
        class: clazz,
        visibility_filter: visibility_filter_json(@offering.report_embeddable_filter),
        anonymous_report: @offering.anonymous_report,
        is_offering_external: @offering.runnable.is_a?(ExternalActivity),
        hide_controls: @hide_controls
    }
  end

  # Helpers that provide class description:

  def class_json
    clazz = @offering.clazz
    section = clazz.section && clazz.section.length > 0 ? clazz.section : nil
    section = section ? " (#{section})" : ""
    {
      name: clazz.name + section,
      students: @students
                    .sort_by { |s| "#{s.last_name} #{s.first_name}".downcase }
                    .map     { |s| student_json(s) }
    }
  end

  def student_json(student)
    started_offering = student.report_learners.where(offering_id: @offering.id).count > 0
    {
      id: student.id,
      name: student.name,
      first_name: student.first_name,
      last_name: student.last_name,
      started_offering:  started_offering
    }
  end


  # Helpers that provide student answers grouped by embeddable key:
  def get_student_answers
    # Collect all the student answers for given offering.
    student_ids = @students.map { |s| s.id }
    report_learners = Report::Learner.where(offering_id: @offering.id, student_id: student_ids)

    answers = report_learners.map do |report_learner|
      student_id = report_learner.student_id
      report_learner.answers.map do |embeddable_key, answer|
        # Process some answers type to provide cleaner format, names, etc.
        question_type = API::V1::Report.embeddable_type(embeddable_key)
        answer[:type] = question_type
        answer[:embeddable_key] = embeddable_key
        answer[:student_id] = student_id
        if question_type == 'Embeddable::MultipleChoice'
          process_multiple_choice_answer(answer)
        elsif question_type == 'Embeddable::ImageQuestion'
          process_image_question_answer(answer)
        end
        answer
      end
    end
    # Flatten answers and group them by the embeddable key.
    answers.flatten.sort_by { |s| s[:student_name] }.group_by { |a| a[:embeddable_key] }
  end

  def no_answer_for_student_id(student_id, embeddable_key='fake-emb-key|0')
    {
        student_id: student_id,
        answer: nil,
        type: 'NoAnswer',
        feedback: nil,
        needs_review: false,
        score: nil,
        feedbacks: [],
        embeddable_key: embeddable_key
    }
  end

  def provide_no_answer_entries(answers, students_json)
    # Provide "no answer" entries for students who started activity, but didn't respond to given question.
    default_answer_entries = students_json.map { |s| no_answer_for_student_id(s[:id]) }
    answers.each do |embeddable_key, embeddable_answers|
      student_found = {}
      embeddable_answers.each { |answer| student_found[answer[:student_id]] = true }
      default_answer_entries.each do |default_answer|
        unless student_found.fetch(default_answer[:student_id], false)
          ans = default_answer.clone
          ans[:embeddable_key] = embeddable_key
          answers[embeddable_key].push(ans)
        end
      end
    end
  end

  def process_multiple_choice_answer(hash)
    # Make naming more consistent, otherwise we would have crazy sequence of [:answers][:answer][:answer] keys.
    hash[:answer] = hash[:answer].map do |a|
      {
        id: a[:choice_id],
        choice: a[:answer],
        is_correct: a[:correct]
      }
    end
  end

  def process_image_question_answer(hash)
    # Filter out useless Blob description, provide image URL instead (and note / annotation).
    ans = hash[:answer]
    if ans[:type] === 'Dataservice::Blob'
      ans[:image_url] = dataservice_blob_raw_url(id: ans[:id], token: ans[:token],
                                                 protocol: @protocol, host: @host_with_port)
      # Skip unnecessary attributes, leave only image url and note.
      ans.slice!(:image_url, :note)
    end
  end

  # Helpers that provide the final structure of an offering plus related answers for each question:

  def report_json(answers)
    runnable =  @offering.runnable
    if @activity_id
      runnable = Activity.find(@activity_id)
    end

    if runnable.is_a?(ExternalActivity) && runnable.template
      runnable = runnable.template
    end
    # Provide chain of associations to load to avoid N+1 queries (values obtained thanks to Bullet gem).
    associations_to_load = {sections: {pages: [{page_elements: :embeddable}, :section, {inner_page_pages: :inner_page}]}}
    if runnable.is_a? Investigation
      investigation_json(runnable, answers, associations_to_load)
    elsif runnable.is_a? Activity
      activity_json(runnable, answers, associations_to_load[:sections])
    end
  end

  def investigation_json(investigation, answers, associations_to_load=nil)
    activities = associations_to_load ? investigation.activities.includes(associations_to_load) : investigation.activities
    {
      id: investigation.id,
      type: 'Investigation',
      name: investigation.name,
      children: activities.map { |a| activity_json(a, answers) }
    }
  end

  def activity_json(activity, answers, associations_to_load=nil)
    sections = associations_to_load ? activity.sections.includes(associations_to_load) : activity.sections
    activity_feedback = Portal::OfferingActivityFeedback.for_offering_and_activity(@offering, activity)
    {
      id: activity.id,
      type: 'Activity',
      name: activity.name,
      activity_feedback_id: activity_feedback.id,
      enable_text_feedback: activity_feedback.enable_text_feedback,
      score_type: activity_feedback.score_type,
      max_score: activity_feedback.max_score,
      activity_feedback:  @offering.learners.map { |l| learner_activity_feedback_json(l,activity_feedback) },
      children: sections.map { |s| section_json(s, answers) }
    }
  end

  def learner_activity_feedback_json(learner, activity_feedback)
    student = learner.student
    learner_activity_feedbacks = Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner, activity_feedback)
    return {
      "student_id": student.id,
      "learner_id": learner.id,
      "feedbacks": learner_activity_feedbacks.map do |feedback|
        {
          score: feedback.score,
          feedback: feedback.text_feedback,
          has_been_reviewed: feedback.has_been_reviewed
        }
      end
    }
  end

  def section_json(section, answers)
    {
      id: section.id,
      type: 'Section',
      name: section.name,
      children: section.pages.map { |p| page_json(p, answers) }
    }
  end

  def page_json(page, answers)
    {
      id: page.id,
      type: 'Page',
      name: page.name,
      url: page.url,
      children: page.page_elements.includes(:page).map { |pe| embeddable_json(pe.question_number, pe.embeddable, answers) }
    }
  end

  IGNORED_EMBEDDABLE_KEYS = ['created_at', 'updated_at', 'uuid', 'user_id', 'external_id']

  def embeddable_json(question_number, embeddable, answers)
    # Provide as much information about embeddable as we can, but skip some attributes
    # to make results more readable and clean.
    feedback_data = Portal::OfferingEmbeddableMetadata.find_or_create_by_offering_id_and_embeddable_id_and_embeddable_type(@offering.id, embeddable.id, embeddable.class.name)
    hash = embeddable.attributes.clone.except(*IGNORED_EMBEDDABLE_KEYS)
    key = API::V1::Report.embeddable_key(embeddable)
    hash[:key] = key
    hash[:type] = embeddable.class.to_s
    hash[:question_number] = question_number
    hash[:answers] = answers[key] || no_answers(key)
    hash[:feedback_enabled] = feedback_data.enable_text_feedback?
    hash[:score_enabled] = feedback_data.enable_score?
    hash[:max_score] = feedback_data.max_score || 0

    # We want to remove markup from the prompt and name. Even though
    # Markup is stript, HTML entities are preserved, eg `&deg`;
    # Do this without creating new keys in hash.
    if hash[:prompt]
      hash[:prompt] = ActionController::Base.helpers.strip_tags(hash[:prompt])
    end
    if hash[:name]
      hash[:name] = ActionController::Base.helpers.strip_tags(hash[:name])
    end
    if embeddable.is_a? Embeddable::MultipleChoice
      process_multiple_choice(hash, embeddable)
    elsif embeddable.is_a? Embeddable::Iframe
      process_iframe(hash, embeddable)
    end
    hash
  end

  def process_multiple_choice(hash, embeddable)
    # Add available choices list.
    hash[:choices] = embeddable.choices.map do |c|
      {
        id: c.id,
        choice: c.choice,
        is_correct: c.is_correct
      }
    end
  end

  def process_iframe(hash, embeddable)
    # Filter out null answers.
    hash[:answers].select { |a| a[:answer].present? }.each do |answer|
      # Pass these properties to answer too.
      answer[:display_in_iframe] = embeddable.display_in_iframe
      answer[:url] = embeddable.url
      answer[:width] = embeddable.width
      answer[:height] = embeddable.height
    end
  end

  def no_answers(embeddable_key)
    @students.map { |s| no_answer_for_student_id(s.id, embeddable_key) }
  end

  # Visibility filter:
  def visibility_filter_json(filter)
    {
      active: !filter.ignore,
      questions: filter.embeddable_keys
    }
  end

  # Other helpers:


  def self.decode_embeddable(embeddable_key)
    type,id = embeddable_key.split("|")
  end

  def self.embeddable_type(embeddable_key)
    return self.decode_embeddable(embeddable_key)[0]
  end

  def self.embeddable_key(embeddable)
    "#{embeddable.class.to_s}|#{embeddable.id}"
  end

  def self.decode_answer_key(answer_key)
    Report::Learner.decode_answer_key(answer_key)
  end

  def self.encode_answer_key(saveable)
    Report::Learner.encode_answer_key(saveable)
  end

  def self.update_feedback_settings(offering, feedback_settings)
    return false unless feedback_settings.has_key? 'embeddable_key'
    type, id = self.decode_embeddable(feedback_settings['embeddable_key'])
    meta = Portal:: OfferingEmbeddableMetadata.find_or_create_by_offering_id_and_embeddable_id_and_embeddable_type(offering.id, id, type)
    ['max_score', 'enable_text_feedback', 'enable_score'].each do |key|
      if feedback_settings.has_key?(key)
        meta.update_attribute(key.to_sym, feedback_settings[key])
      end
    end
  end

  def self.submit_feedback(answer_feedback_hash)
    answer_key = answer_feedback_hash.delete('answer_key')
    return unless answer_key
    # see Portal::Report::Learner.serialize_record_key
    type,id = API::V1::Report.decode_answer_key(answer_key)
    if type && id
      answer = type.constantize.find(id)
    end

    return unless answer
    if answer.respond_to? :add_feedback # the answer is a saveable
      answer.add_feedback(answer_feedback_hash)
    else # assume answer has feedback columns.
      answer.update_attributes(answer_feedback_hash)
    end
    # All answers should delegate learner to their saveables...
    # We need to update fields, because the answer is serialized in the report learner
    if answer.respond_to?(:learner) && answer.learner
      answer.learner.report_learner.update_fields()
    end
  end

  def self.update_activity_feedback_settings(activity_feedback_hash)
    activity_feedback_id = activity_feedback_hash.delete('activity_feedback_id')
    return false unless activity_feedback_id
    activity_feedback_settings = Portal::OfferingActivityFeedback.find(activity_feedback_id)
    activity_feedback_settings.set_feedback_options(activity_feedback_hash.symbolize_keys)
  end

  def self.submit_activity_feedback(activity_feedback_hash)
    learner_id = activity_feedback_hash.delete('learner_id')
    activity_feedback_id = activity_feedback_hash.delete('activity_feedback_id')
    return unless learner_id && activity_feedback_id
    Portal::LearnerActivityFeedback.update_feedback(learner_id, activity_feedback_id, activity_feedback_hash.symbolize_keys)
  end

end