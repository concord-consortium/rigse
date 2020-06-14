module SaveableExtraction
  
  def logger
    # It doesn't appear that any saveable extractors define 'logger'
    # but we can do this as a safeguard anyway.
    return @logger || Rails.logger
  end

  def extract_everything(extractor = Otrunk::ObjectExtractor.new(self.otml))
    return unless learner
    extract_open_responses(extractor)
    extract_multiple_choices(extractor)
    extract_image_questions(extractor)
  end

  def extract_open_responses(extractor = Otrunk::ObjectExtractor.new(self.otml))
    @offering_id = learner.offering.id
    @learner_id = learner.id
    extractor.find_all('OTText') do |text|
      parent_id = extractor.get_parent_id(text)
      if parent_id && parent_id =~ /open_response_(\d+)/
        process_open_response($1.to_i, extractor.get_text_property(text, 'text'))
      end
    end
  end

  def process_open_response(parent_id, answer, is_final = nil)
    if Embeddable::OpenResponse.find_by_id(parent_id)
      saveable_open_response = Saveable::OpenResponse.where(learner_id: @learner_id, offering_id: @offering_id, open_response_id: parent_id).first_or_create
      if saveable_open_response.response_count == 0 ||
         saveable_open_response.answers.last.answer != answer ||
         saveable_open_response.answers.last.is_final != is_final

        saveable_open_response.answers.create(:bundle_content_id => self.id, :answer => answer, :is_final => is_final)
      end
    else
      logger.error("Missing Embeddable::OpenResponse id: #{parent_id}")
    end
  end

  def extract_multiple_choices(extractor = Otrunk::ObjectExtractor.new(self.otml))
    @offering_id = self.learner.offering.id
    @learner_id = self.learner.id
    extractor.find_all('currentChoices') do |choice|
      choices = choice.children
      choices_to_process = []
      choices.each do |c|
        next unless c.elem?
        choices_to_process << $1.to_i if c.has_attribute?('refid') && c.get_attribute('refid') =~ /(?:embeddable__)?multiple_choice_choice_(\d+)/
        choices_to_process << $1.to_i if c.has_attribute?('local_id') && c.get_attribute('local_id') =~ /(?:embeddable__)?multiple_choice_choice_(\d+)/
      end
      rationales = extract_multiple_choice_rationales(choice.parent)
      process_multiple_choice(nil, choices_to_process.uniq, rationales)
    end
  end

  def extract_multiple_choice_rationales(ot_choice_elem)
    rationales = {}
    ot_choice_elem.search('./rationales/entry').each do |entry|
      choice = $1.to_i if entry.get_attribute('key') =~ /(?:embeddable__)?multiple_choice_choice_(\d+)/
      rationale = entry.search('./string').map {|s| s.text }
      rationales[choice] = rationale.first if choice && rationale.first
    end
    return rationales
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
      saveable_answer = saveable.answers.create(:bundle_content_id => self.id, :multiple_choice_id => embeddable_id, :is_final => is_final)
      return
    end

    choice = Embeddable::MultipleChoiceChoice.find_by_id(choice_ids.first, :include => :multiple_choice)
    multiple_choice = choice ? choice.multiple_choice : nil

    if multiple_choice && choice

      saveable = Saveable::MultipleChoice.where(learner_id: @learner_id, offering_id: @offering_id, multiple_choice_id: multiple_choice.id).first_or_create

      if saveable.answers.empty? || # we don't have any answers yet
         saveable.answers.last.answer.size != choice_ids.size || # the number of selected choices differs
         ( !(saveable.answers.last.answer[0].key?(:choice_id)) ) || # a placeholder value indicating "no selection" is present.
         ((saveable.answers.last.rationale_choices.map{|rc| rc.choice_id} - choice_ids).size != 0) || # the actual selections differ
         ((saveable.answers.last.rationale_choices.map{|rc| rc.rationale}.compact - rationales.values).size != 0) || # the actual rationales differ
         saveable.answers.last.is_final != is_final # is_final differs (answer is explicitly submitted by learner)

        saveable_answer = saveable.answers.create(:bundle_content_id => self.id, :multiple_choice_id => multiple_choice.id, :is_final => is_final)
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

  def extract_image_questions(extractor = Otrunk::ObjectExtractor.new(self.otml))
    @offering_id = self.learner.offering.id
    @learner_id = self.learner.id
    extractor.find_all('OTLabbookEntryChooser') do |chooser|
      parent_id = extractor.get_parent_id(chooser)
      if parent_id && parent_id =~ /image_question_(\d+)/
        saveable_image_question = Saveable::ImageQuestion.where(learner_id: @learner_id, offering_id: @offering_id, image_question_id: $1).first_or_create
        answer = extractor.get_property_path(chooser, 'embeddedEntries/oTObject').last
        note = extractor.get_property_path(chooser, 'embeddedEntries').last
        note = extractor.get_text_property(note, 'note') if note
        src = answer.nil? ? nil : extractor.get_text_property(answer, 'src')
        if src =~ BlobExtraction::BLOB_URL_REGEXP
          blob_id = $1
          if saveable_image_question.response_count == 0 || saveable_image_question.answers.last.blob_id != blob_id.to_i
            saveable_image_question.answers.create(:bundle_content_id => self.id, :blob_id => blob_id, :note => note)
          end
        else
          logger.error("Unknown image question object: #{answer}")
        end
      else
        logger.error("Missing Embeddable::ImageQuestion id: #{parent_id}")
      end
    end
  end
end
