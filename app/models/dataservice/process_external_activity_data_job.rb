class Dataservice::ProcessExternalActivityDataJob < Struct.new(:learner_id, :content)
  include SaveableExtraction

  class UnknownRespose < NameError; end
  class MissingAnswer  < NameError; end
  def perform
    all_data = JSON.parse(content) rescue {}
    learner = Portal::Learner.find(learner_id)
    offering = learner.offering
    template = offering.runnable.template

    # setup for SaveableExtraction
    @learner_id = learner_id
    @offering_id = offering.id

    # process the json data
    all_data.each do |student_response|
      begin
        case student_response["type"]
        when "open_response"
          embeddable = template.open_responses.detect {|e| e.external_id == student_response["question_id"]}
          internal_process_open_response(student_response, embeddable)
        when "multiple_choice"
          embeddable = template.multiple_choices.detect {|e| e.external_id == student_response["question_id"]}
          internal_process_multiple_choice(student_response, embeddable)
        when "image_question"
          embeddable = template.image_questions.detect {|e| e.external_id == student_response["question_id"]}
          internal_process_image_question(student_response, embeddable)
        when "external_link"
          if student_response["question_type"] == "iframe interactive"
            embeddable = template.iframes.detect {|e| e.external_id == student_response["question_id"]}
            internal_process_external_link(student_response, embeddable)
          end
        else
          raise UnknownRespose.new("type: #{student_response["type"]}\nContent: #{content}")
        end
      # We could broaden this to StdErr, but this should catch most cases
      # which will be NPE-like cases
      rescue NameError => stderr
        log_exception(stderr, learner_id, student_response)
      end
    end
    learner.report_learner.last_run = Time.now
    learner.report_learner.update_fields if learner
  end

  def internal_process_open_response(data, embeddable)
    if data["answer"].nil?
      raise MissingAnswer.new("Open response is missing answer value")
    end
    process_open_response(embeddable.id, data["answer"], data["is_final"])
  end

  def internal_process_multiple_choice(data, embeddable)
    choice_ids = data["answer_ids"].map {|aid| choice = embeddable.choices.detect{|ch| ch.external_id == aid }; choice ? choice.id : nil }
    process_multiple_choice(choice_ids.compact.uniq, {}, data["is_final"])
  end

  def internal_process_image_question(data,embeddable)
    saveable_image_question = Saveable::ImageQuestion.find_or_create_by_learner_id_and_offering_id_and_image_question_id(@learner_id, @offering_id, embeddable.id)
    saveable_image_question.add_external_answer(data["answer"], data["image_url"], data["is_final"])
  end

  def internal_process_external_link(data,embeddable)
    saveable_external_link = Saveable::ExternalLink.find_or_create_by_learner_id_and_offering_id_and_embeddable_type_and_embeddable_id(@learner_id, @offering_id, embeddable.class.name, embeddable.id)
    saveable_external_link.answers.create(url: data["answer"], is_final: data["is_final"])
  end

  # stub id method, for SaveableExtraction compatibility
  def id
    nil
  end

  protected
  def log_exception(exception, learner_id, response)
    Rails.logger.info("ProcessExternalActivityDataJob swallowing exception: #{exception}\n #{exception.backtrace}")
    NewRelic::Agent.notice_error(exception, {custum_params: {learner_id: learner_id, response:response}} )
  end

end
