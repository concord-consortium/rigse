class Assessments::LearnerDataImporter
  require 'json'
  require 'uri'

  def initialize(couch_db_url)
    @couch_url = couch_db_url
    @changed = []
    # ensure it exists
    info = Notifications::AssessmentImportInfo.find_or_create_by_database(@couch_url, :last_seq => 0)
    json = {"results" => []}
    Notifications::AssessmentImportInfo.transaction do
      # lock it this time, so that other importers won't re-run the same documents we're about to do
      info = Notifications::AssessmentImportInfo.find(:first, :conditions => {:database => @couch_url}, :lock => true)
      @since = info.last_seq
      changes = URI.parse(@couch_url + "/_changes?since=#{@since}").read
      json = JSON.parse(changes)
      @last_seq = json["last_seq"].to_i
      info.last_seq = @last_seq
      info.save
    end
    json["results"].each do |item|
      @changed << {:db => item["id"], :rev => item["changes"].first["rev"]}
    end
  end

  def run
    @changed.each do |info|
      # get the database
      doc = URI.parse("#{@couch_url}/#{info[:db]}?rev=#{info[:rev]}").read
      import(doc)
    end
  end

  private

  def import(document)
    json = JSON.parse(document)
    jlearner = json["learner"]
    if json["learner"] && json["learner"]["url"] && json["learner"]["url"] =~ /learner\/(\d+)/
      learner = Portal::Learner.find($1.to_i)
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
  end

  def object_for_dom_id(dom_id)
    if dom_id =~ /_open_response_(\d+)$/
      return Embeddable::OpenResponse.find($1.to_i)
    elsif dom_id =~ /_multiple_choice_(\d+)$/
      return Embeddable::MultipleChoice.find($1.to_i)
    end
    # we can't handle whatever this is right now
    return nil
  end

  def process_question(json, question, learner)
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

  def process_open_response(open_response, learner, answer)
    saveable_open_response = Saveable::OpenResponse.find_or_create_by_learner_id_and_offering_id_and_open_response_id(learner.id, learner.offering.id, open_response.id)
    if saveable_open_response.response_count == 0 || saveable_open_response.answers.last.answer != answer
      saveable_open_response.answers.create(:answer => answer)
    end
  end

  def process_multiple_choice(choice, learner)
    multiple_choice = choice.multiple_choice
    saveable = Saveable::MultipleChoice.find_or_create_by_learner_id_and_offering_id_and_multiple_choice_id(learner.id, learner.offering.id, multiple_choice.id)
    if saveable.answers.empty? || saveable.answers.last.choice_id != choice.id
      saveable.answers.create(:choice_id => choice.id)
    end
  end
end
