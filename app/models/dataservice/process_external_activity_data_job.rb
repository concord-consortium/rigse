class Dataservice::ProcessExternalActivityDataJob
  attr_accessor :learner_id
  attr_accessor :content
  attr_accessor :learner
  attr_accessor :answers

  include SaveableExtraction

  class UnknownRespose < NameError; end
  class MissingAnswer  < NameError; end

  def initialize(_learner_id, _content)
    self.learner_id = _learner_id
    self.content = _content
    self.answers = JSON.parse(_content) rescue {}
    self.learner = Portal::Learner.find(learner_id)
  end

  def perform
    offering = learner.offering
    template = offering.runnable.template
    # setup for SaveableExtractionlearn
    @learner_id = learner_id
    @offering_id = offering.id

    # process the json data
    answers.each do |student_response|

      # Delayed::Worker.logger.debug( "Processing student_response " <<
	  #                              "#{student_response}" )

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
        when "interactive"
          embeddable = template.iframes.detect {|e| e.external_id == student_response["question_id"]}
          internal_process_interactive(student_response, embeddable)
        else
          raise UnknownRespose.new("type: #{student_response["type"]}\nContent: #{content}")
        end

      #
      # We could broaden this to StdErr, but this should catch most cases
      # which will be NPE-like cases
      #
      rescue NameError => e

        # Delayed::Worker.logger.debug("*** rescue #{e}")
        # Delayed::Worker.logger.debug("*** learner_id #{learner_id}")
        # Delayed::Worker.logger.debug("*** student_ response " <<
        #                               "#{student_response}")
        # Delayed::Worker.logger.error e.backtrace.join("\n")

        log_exception(e, learner_id, student_response)

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

  def internal_process_interactive(data,embeddable)
    saveable_interactive = Saveable::Interactive.find_or_create_by_learner_id_and_offering_id_and_iframe_id(@learner_id, @offering_id, embeddable.id)
    saveable_interactive.answers.create(state: data["answer"], is_final: data["is_final"])
  end

  # stub id method, for SaveableExtraction compatibility
  def id
    nil
  end

  protected
  def log_exception(exception, learner_id, response)
    Rails.logger.info("ProcessExternalActivityDataJob swallowing exception: #{exception}\n #{exception.backtrace}")
    NewRelic::Agent.notice_error(exception, {custom_params: {learner_id: learner_id, response:response}} )
  end

end
