class API::V1::Report
  include RailsPortal::Application.routes.url_helpers

  def initialize(offering, protocol, host_with_port)
    @offering = offering
    @protocol = protocol
    @host_with_port = host_with_port
  end

  def to_json
    clazz = class_json
    answers_hash = get_student_answers
    provide_no_answer_entries(answers_hash, clazz[:students])
    {
      report: report_json(answers_hash),
      class: clazz,
      visibility_filter: visibility_filter_json(@offering.report_embeddable_filter),
      anonymous_report: @offering.anonymous_report,
      is_offering_external: @offering.runnable.is_a?(ExternalActivity)
    }
  end

  # Helpers that provide class description:

  def class_json
    clazz = @offering.clazz
    section = clazz.section && clazz.section.length > 0 ? clazz.section : nil
    section = section ? " (#{section})" : ""
    {
      name: clazz.name + section,
      students: clazz.students.includes(:user).map { |s| student_json(s) }.sort_by { |s| s[:name] }
    }
  end

  def student_json(student)
    started_offering = student.report_learners.where(offering_id: @offering.id).count > 0
    {
      id: student.id,
      name: student.name,
      started_offering:  started_offering
    }
  end

  # Helpers that provide student answers grouped by embeddable key:

  def get_student_answers
    # Collect all the student answers for given offering.
    answers = Report::Learner.where(offering_id: @offering.id).map do |report_learner|
      student_id = report_learner.student_id
      answers = []
      report_learner.answers.map do |embeddable_key, answer|
        # Process some answers type to provide cleaner format, names, etc.
        question_type = embeddable_type(embeddable_key)
        answer[:type] = question_type
        answer[:embeddable_key] = embeddable_key
        answer[:student_id] = student_id
        if question_type == 'Embeddable::MultipleChoice'
          process_multiple_choice_answer(answer)
        elsif question_type == 'Embeddable::ImageQuestion'
          process_image_question_answer(answer)
        end
        answers.push(answer)
      end
      answers
    end
    # Flatten answers and group them by the embeddable key.
    answers.flatten.sort_by { |s| s[:student_name] }.group_by { |a| a[:embeddable_key] }
  end

  def provide_no_answer_entries(answers, students_json)
    # Provide "no answer" entries for students who started activity, but didn't respond to given question.
    default_answer_entries = students_json.select { |s| s[:started_offering] }.map do |s|
      {
        student_id: s[:id],
        answer: nil,
        type: 'NoAnswer'
      }
    end
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
    runnable = @offering.runnable
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
    {
      id: activity.id,
      type: 'Activity',
      name: activity.name,
      children: sections.map { |s| section_json(s, answers) }
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
      children: page.page_elements.map { |pe| embeddable_json(pe.question_number, pe.embeddable, answers) }
    }
  end

  IGNORED_EMBEDDABLE_KEYS = ['created_at', 'updated_at', 'uuid', 'user_id', 'external_id']

  def embeddable_json(question_number, embeddable, answers)
    # Provide as much information about embeddable as we can, but skip some attributes
    # to make results more readable and clean.
    hash = embeddable.attributes.clone.except(*IGNORED_EMBEDDABLE_KEYS)
    key = embeddable_key(embeddable)
    hash[:key] = key
    hash[:type] = embeddable.class.to_s
    hash[:question_number] = question_number
    hash[:answers] = answers[key] || [] #when no students have answered

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
      answer[:width] = embeddable.width
      answer[:height] = embeddable.height
    end
  end

  # Visibility filter:

  def visibility_filter_json(filter)
    {
      active: !filter.ignore,
      questions: filter.embeddable_keys
    }
  end

  # Other helpers:

  def embeddable_key(embeddable)
    "#{embeddable.class.to_s}|#{embeddable.id}"
  end

  def embeddable_type(embeddable_key)
    embeddable_key.split('|')[0]
  end

end
