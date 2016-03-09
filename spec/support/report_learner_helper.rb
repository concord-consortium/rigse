module ReportLearnerSpecHelper
  def saveable_for(embeddable)
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

  def add_answer(embeddable, answer_hash)
    case embeddable
      when Embeddable::OpenResponse
        saveable = Saveable::OpenResponse.find_or_create_by_learner_id_and_offering_id_and_open_response_id(learner.id,learner.offering.id, embeddable.id)
        saveable.answers.create!(answer_hash)
      when Embeddable::ImageQuestion
        saveable = Saveable::ImageQuestion.find_or_create_by_learner_id_and_offering_id_and_image_question_id(learner.id, learner.offering.id, embeddable.id)
        saveable.answers.create!(answer_hash)
      # TODO: test mutliple choices and others, that are hard to make... SO HARD TO MAKE!
    end
  end
end