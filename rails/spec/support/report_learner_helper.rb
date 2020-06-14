module ReportLearnerSpecHelper

  def stub_all_reportables(runnableClass, embeddables)
    allow_any_instance_of(runnableClass).to receive(:reportable_elements).and_return( embeddables.map { |e| {embeddable: e} } )
  end

  # must have a learner in scenario's setup
  def saveable_for(embeddable)
    find_saveable_for_learner(learner, embeddable)
  end

  def find_saveable_for_learner(learner, embeddable)
    args = [learner.id, embeddable.id]
    case embeddable
      when Embeddable::MultipleChoice
        Saveable::MultipleChoice.find_by_learner_id_and_multiple_choice_id(*args)
      when Embeddable::OpenResponse
        Saveable::OpenResponse.find_by_learner_id_and_open_response_id(*args)
      when Embeddable::ImageQuestion
        Saveable::ImageQuestion.find_by_learner_id_and_image_question_id(*args)
      else
        nil
    end
  end

  def answers_for(embeddable)
    if saveable = saveable_for(embeddable)
      saveable.answers
    else
      nil
    end
  end

  # must have a learner in the scenario
  def add_answer(embeddable, answer_hash)
    add_answer_for_learner(learner,embeddable, answer_hash)
  end

  def add_answer_for_learner(learner, embeddable, answer_hash)
    case embeddable
      when Embeddable::OpenResponse
        saveable = Saveable::OpenResponse.where(learner_id: learner.id, offering_id: learner.offering.id, open_response_id: embeddable.id).first_or_create
        saveable.answers.create!(answer_hash)
      when Embeddable::ImageQuestion
        saveable = Saveable::ImageQuestion.where(learner_id: learner.id, offering_id: learner.offering.id, image_question_id: embeddable.id).first_or_create
        saveable.answers.create!(answer_hash)
      # TODO: test mutliple choices and others, that are harder to make...
    end
  end

  # A bit more friendly helper that accepts student and automatically handles learner and report_learner updates.
  def add_answer_for_student(student, offering, question, answer_hash)
    learner = Portal::Learner.where(offering_id: offering.id, student_id: student.id).first_or_create
    add_answer_for_learner(learner, question, answer_hash)
    learner.report_learner.update_answers
    learner.report_learner.last_run = Time.now
    learner.report_learner.save!
  end
end
