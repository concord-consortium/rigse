module SaveableExtraction

  def logger
    # It doesn't appear that any saveable extractors define 'logger'
    # but we can do this as a safeguard anyway.
    return @logger || Rails.logger
  end

  def process_open_response(parent_id, answer, is_final = nil)
    if Embeddable::OpenResponse.find_by_id(parent_id)
      saveable_open_response = Saveable::OpenResponse.where(learner_id: @learner_id, offering_id: @offering_id, open_response_id: parent_id).first_or_create
      if saveable_open_response.response_count == 0 ||
         saveable_open_response.answers.last.answer != answer ||
         saveable_open_response.answers.last.is_final != is_final

        saveable_open_response.answers.create(:answer => answer, :is_final => is_final)
      end
    else
      logger.error("Missing Embeddable::OpenResponse id: #{parent_id}")
    end
  end

  #
  # Persist a multiple choice selection.
  #
  # embeddable_id   The multiple_choice_id that the choice_ids belong to.
  #                 This can be nil if a non-empty array of choice_ids
  #                 is supplied.
  # choice_ids      The choice ids to set as selected.
  # rationales      The rationales.
  # is_final        is_final.
  #
  #
  def process_multiple_choice(  embeddable_id,
                                choice_ids,
                                rationales = {},
                                is_final = nil )

    if embeddable_id && choice_ids.count == 0
      #
      # User is unselecting a previous selection.
      # Do not associate answers with this question.
      #
      saveable = Saveable::MultipleChoice.where(learner_id: @learner_id, offering_id: @offering_id, multiple_choice_id: embeddable_id).first_or_create
      saveable_answer = saveable.answers.create(:multiple_choice_id => embeddable_id, :is_final => is_final)
      return
    end

    choice = Embeddable::MultipleChoiceChoice.includes(:multiple_choice).find_by_id(choice_ids.first)
    multiple_choice = choice ? choice.multiple_choice : nil

    if multiple_choice && choice

      saveable = Saveable::MultipleChoice.where(learner_id: @learner_id, offering_id: @offering_id, multiple_choice_id: multiple_choice.id).first_or_create

      if saveable.answers.empty? || # we don't have any answers yet
         saveable.answers.last.answer.size != choice_ids.size || # the number of selected choices differs
         ( !(saveable.answers.last.answer[0].key?(:choice_id)) ) || # a placeholder value indicating "no selection" is present.
         ((saveable.answers.last.rationale_choices.map{|rc| rc.choice_id} - choice_ids).size != 0) || # the actual selections differ
         ((saveable.answers.last.rationale_choices.map{|rc| rc.rationale}.compact - rationales.values).size != 0) || # the actual rationales differ
         saveable.answers.last.is_final != is_final # is_final differs (answer is explicitly submitted by learner)

        saveable_answer = saveable.answers.create(:multiple_choice_id => multiple_choice.id, :is_final => is_final)
        choice_ids.each do |choice_id|
          Saveable::MultipleChoiceRationaleChoice.create(:choice_id => choice_id, :answer_id => saveable_answer.id, :rationale => rationales[choice_id])
        end
      end
    else
      if ! choice
        logger.error("Missing Embeddable::MultipleChoiceChoice id: #{choice_ids.join(",")}")
      elsif ! multiple_choice
        logger.error("Missing Embeddable::MultipleChoice id: #{choice.multiple_choice_id}")
      end
    end
  end

end
