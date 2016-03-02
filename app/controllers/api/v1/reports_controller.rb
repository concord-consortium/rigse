class API::V1::ReportsController < API::APIController
  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  def pundit_user_not_authorized(exception)
    unauthorized
  end

  # GET api/v1/reports/offering?id=:id
  # Example response: https://gist.github.com/pjanik/b831b67f659e709931bf
  def offering
    offering = Portal::Offering.find(params[:id])
    authorize offering, :api_report?
    render json: response_json(offering)
  end

  private

  def response_json(offering)
    answers_hash = get_student_answers(offering)
    embeddable_filter = offering.report_embeddable_filter
    visibility_hash  = Hash[embeddable_filter.embeddables.collect { |v| [embeddable_key(v), true] }]
    {
      embeddables_filtering_enabled: !embeddable_filter.ignore,
      # Might be useful e.g. to filter out sections that doesn't make sense in LARA activities context.
      is_offering_external: offering.runnable.is_a?(ExternalActivity),
      class: class_json(offering),
      report: report_json(offering, answers_hash, visibility_hash)
    }
  end

  # Helpers that provide class description:

  def class_json(offering)
    clazz = offering.clazz
    section = clazz.section && clazz.section.length > 0 ? clazz.section : nil
    section = section ? " (#{section})" : ""
    {
      name: clazz.name + section,
      students: clazz.students.includes(:user).map { |s| student_json(s, offering) }
    }
  end

  def student_json(student, offering)
    started_offering = student.report_learners.where(offering_id: offering.id).count > 0
    {
      id: student.id,
      name: student.name,
      started_offering:  started_offering
    }
  end

  # Helpers that provide student answers grouped by embeddable key:

  def get_student_answers(offering)
    # Collect all the student answers for given offering.
    answers = Report::Learner.where(offering_id: offering.id).map do |report_learner|
      student_name = report_learner.student_name
      student_id = report_learner.student_id
      answers = []
      report_learner.answers.map do |embeddable_key, answer|
        answer[:embeddable_key] = embeddable_key
        answer[:student_id] = student_id
        answer[:student_name] = student_name
        # Process some answers type to provide cleaner format, names, etc.
        question_type = embeddable_type(embeddable_key)
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
    answers.flatten.group_by { |a| a[:embeddable_key] }
  end

  def process_multiple_choice_answer(hash)
    # Make naming more consistent, otherwise we would have crazy sequence of [:answers][:answer][:answer] keys.
    hash[:answer] = hash[:answer].map do |a|
      {
        choice: a[:answer],
        is_correct: a[:correct]
      }
    end
  end

  def process_image_question_answer(hash)
    # Filter out useless Blob description, provide image URL instead (and note / annotation).
    ans = hash[:answer]
    if ans[:type] === 'Dataservice::Blob'
      ans[:image_url] = dataservice_blob_raw_url(id: ans[:id], token: ans[:token])
      # Skip unnecessary attributes, leave only image url and note.
      ans.slice!(:image_url, :note)
    end
  end

  # Helpers that provide the final structure of an offering plus visibility and related answers for each question:

  def report_json(offering, answers, visibility)
    runnable = offering.runnable
    if runnable.is_a?(ExternalActivity) && runnable.template
      runnable = runnable.template
    end
    # Provide chain of associations to load to avoid N+1 queries (values obtained thanks to Bullet gem).
    associations_to_load = {sections: {pages: [{page_elements: :embeddable}, :section, {inner_page_pages: :inner_page}]}}
    if runnable.is_a? Investigation
      investigation_json(runnable, answers, visibility, associations_to_load)
    elsif runnable.is_a? Activity
      activity_json(runnable, answers, visibility, associations_to_load[:sections])
    end
  end

  def investigation_json(investigation, answers, visibility, associations_to_load=nil)
    activities = associations_to_load ? investigation.activities.includes(associations_to_load) : investigation.activities
    {
      id: investigation.id,
      type: 'Investigation',
      name: investigation.name,
      children: activities.map { |a| activity_json(a, answers, visibility) }
    }
  end

  def activity_json(activity, answers, visibility, associations_to_load=nil)
    sections = associations_to_load ? activity.sections.includes(associations_to_load) : activity.sections
    {
      id: activity.id,
      type: 'Activity',
      name: activity.name,
      children: sections.map { |s| section_json(s, answers, visibility) }
    }
  end

  def section_json(section, answers, visibility)
    {
      id: section.id,
      type: 'Section',
      name: section.name,
      children: section.pages.map { |p| page_json(p, answers, visibility) }
    }
  end

  def page_json(page, answers, visibility)
    {
      id: page.id,
      type: 'Page',
      name: page.name,
      children: page.page_elements.map { |pe| embeddable_json(pe.embeddable, answers, visibility) }
    }
  end

  IGNORED_EMBEDDABLE_KEYS = ['created_at', 'updated_at', 'uuid', 'user_id', 'external_id']

  def embeddable_json(embeddable, answers, visibility)
    # Provide as much information about embeddable as we can, but skip some attributes
    # to make results more readable and clean.
    hash = embeddable.attributes.clone.except(*IGNORED_EMBEDDABLE_KEYS)
    key = embeddable_key(embeddable)
    hash[:type] = embeddable.class.to_s
    hash[:visible_in_report] = visibility.fetch(key, false)
    hash[:answers] = answers[key]
    if embeddable.is_a? Embeddable::MultipleChoice
      process_multiple_choice(hash, embeddable)
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

  # Other helpers:

  def embeddable_key(embeddable)
    "#{embeddable.class.to_s}|#{embeddable.id}"
  end

  def embeddable_type(embeddable_key)
    embeddable_key.split('|')[0]
  end

end
