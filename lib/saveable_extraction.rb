module SaveableExtraction
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

  def process_open_response(parent_id, answer)
    if Embeddable::OpenResponse.find_by_id(parent_id)
      saveable_open_response = Saveable::OpenResponse.find_or_create_by_learner_id_and_offering_id_and_open_response_id(@learner_id, @offering_id, parent_id)
      if saveable_open_response.response_count == 0 || saveable_open_response.answers.last.answer != answer
        saveable_open_response.answers.create(:bundle_content_id => self.id, :answer => answer)
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
      choices.each do |c|
        next unless c.elem?
        process_multiple_choice($1.to_i) if c.has_attribute?('refid') && c.get_attribute('refid') =~ /(?:embeddable__)?multiple_choice_choice_(\d+)/
        process_multiple_choice($1.to_i) if c.has_attribute?('local_id') && c.get_attribute('local_id') =~ /(?:embeddable__)?multiple_choice_choice_(\d+)/
      end
    end
  end

  def process_multiple_choice(choice_id)
    choice = Embeddable::MultipleChoiceChoice.find_by_id(choice_id, :include => :multiple_choice)
    multiple_choice = choice ? choice.multiple_choice : nil
    answer = choice ? choice.choice : ""
    if multiple_choice && choice
      saveable = Saveable::MultipleChoice.find_or_create_by_learner_id_and_offering_id_and_multiple_choice_id(@learner_id, @offering_id, multiple_choice.id)
      if saveable.answers.empty? || saveable.answers.last.answer != answer
        saveable.answers.create(:bundle_content_id => self.id, :choice_id => choice.id)
      end
    else
      if ! choice
        logger.error("Missing Embeddable::MultipleChoiceChoice id: #{choice_id}")
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
        saveable_image_question = Saveable::ImageQuestion.find_or_create_by_learner_id_and_offering_id_and_image_question_id(@learner_id, @offering_id, $1)
        answer = extractor.get_property_path(chooser, 'embeddedEntries/oTObject').last
        src = answer.nil? ? nil : extractor.get_text_property(answer, 'src')
        if src =~ BlobExtraction::BLOB_URL_REGEXP
          blob_id = $1
          if saveable_image_question.response_count == 0 || saveable_image_question.answers.last.blob_id != blob_id.to_i
            saveable_image_question.answers.create(:bundle_content_id => self.id, :blob_id => blob_id)
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
