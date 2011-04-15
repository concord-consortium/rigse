class Assessments::LearnerDataImporter
  require 'json'
  def self.import(document)
    json = JSON.parse(document)
    # activity = Activity.find(json["activity"]["url"].to_i)
    learner = Portal::Learner.find(json["learner"]["url"][/learner\/(\d+)/, 1].to_i)
    json["pages"].each do |jpage|
      if page = Page.find(jpage["url"][/page\/(\d+)$/,1].to_i)
        jpage["steps"].each do |jquestion|
          if question = object_for_dom_id(jquestion["url"][/step\/(\w+)$/, 1])
            # create the saveable for this object and learner
            process_question(jquestion, question, learner)
          end
        end
      end
    end
  end

  private

  def self.object_for_dom_id(dom_id)
    if dom_id =~ /_open_response_(\d+)$/
      return Embeddable::OpenResponse.find($1.to_i)
    elsif dom_id =~ /_multiple_choice_(\d+)$/
      return Embeddable::MultipleChoice.find($1.to_i)
    end
    # we can't handle whatever this is right now
    return nil
  end

  def self.process_question(json, question, learner)
    if question.kind_of? Embeddable::OpenResponse
      answer = json["responseTemplate"]["values"].first
      process_open_response(question, learner, answer)
    elsif question.kind_of? Embeddable::MultipleChoice
      answer = json["responseTemplate"]["values"].first
      # smartgraphs answer indexes are 1-based, ruby uses 0-based arrays
      choice = question.choices[answer.to_i - 1]
      process_multiple_choice(choice, learner)
    end
  end

  def self.process_open_response(open_response, learner, answer)
    saveable_open_response = Saveable::OpenResponse.find_or_create_by_learner_id_and_offering_id_and_open_response_id(learner.id, learner.offering.id, open_response.id)
    if saveable_open_response.response_count == 0 || saveable_open_response.answers.last.answer != answer
      saveable_open_response.answers.create(:answer => answer)
    end
  end

  def self.process_multiple_choice(choice, learner)
    multiple_choice = choice.multiple_choice
    saveable = Saveable::MultipleChoice.find_or_create_by_learner_id_and_offering_id_and_multiple_choice_id(learner.id, learner.offering.id, multiple_choice.id)
    if saveable.answers.empty? || saveable.answers.last.choice_id != choice.id
      saveable.answers.create(:choice_id => choice.id)
    end
  end
end
