require 'spec_helper'

describe Assessments::LearnerDataImporter do
  include ApplicationHelper
  before(:each) do
    user = Factory.create(:user)
    # create an investigation with a single nested page, a single model and a couple questions
    uuid_str = UUIDTools::UUID.timestamp_create.to_s
    options = {
      :name => "Investigation #{uuid_str}",
      :description => "Description",
      :user => user
    }
    investigation = Investigation.create!(options)
    @activity = Activity.create!(options)
    section = Section.create!(options)
    @page = Page.create!(options)

    web_model = WebModel.create!(:user => user,
                                 :name => "Web Model #{uuid_str}",
                                 :url => "http://seeingmath.concord.org/broken_calculator/",
                                 :image_url => "http://seeingmath.concord.org/images/QuadraticTransformer_100.jpg" )
    @model = Embeddable::WebModel.create!(:web_model => web_model, :user => user)
    @open_response = Embeddable::OpenResponse.create!(:name => "OR #{uuid_str}", :prompt => "OR #{uuid_str}")
    @multiple_choice = Embeddable::MultipleChoice.create!(:name => "MC #{uuid_str}", :prompt => "MC #{uuid_str}")
    @choices = @multiple_choice.choices

    investigation.activities << @activity
    @activity.sections << section
    section.pages << @page

    @model.pages << @page
    @open_response.pages << @page
    @multiple_choice.pages << @page

    [investigation, @activity, section, @page, @model, @open_response, @multiple_choice].each {|o| o.save! }

    # create an offering, student and learner for that student
    # generate_default_project_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    # Admin::Project.stub!(:default_project).and_return(@mock_project)

    clazz = Factory.create(:portal_clazz)
    runnable_opts = {
      :name      => "Some Activity",
      :url       => "http://example.com",
      :save_path => "/path/to/save",
      :append_learner_id_to_url => true
    }
    runnable = Factory.create(:external_activity, runnable_opts )
    offering = Factory.create(:portal_offering, {:runnable => runnable, :clazz => clazz})
    student = Factory.create(:portal_student, {:user => @user})
    @learner = Factory.create(:portal_learner, {:offering => offering, :student => student})

    @couch = "http://localhost/db/assessments"
    @changes_uri = URI.parse("#{@couch}/_changes?since=1")
    @changes_since_uri = URI.parse("#{@couch}/_changes")
    @doc_uri = URI.parse("#{@couch}/doc?rev=rev")
    @design_doc_uri = URI.parse("#{@couch}/des?rev=rev")
    init_misc_docs
    OpenURI.should_receive(:open_uri) {|uri,opts|
      out = '{"results":[], "last_seq":1}'
      if uri == URI.parse("#{@couch}/_changes?since=1") ||
         uri == URI.parse("#{@couch}/_changes?since=2")
        out = @changes_doc
      elsif uri == @doc_uri
        out = @learner_data
      elsif uri == @design_doc_uri
        out = @design_doc
      end
      out
    }.at_least(:once)

  end

  it 'should initialize an assessment info object' do
    Notifications::AssessmentImportInfo.delete_all
    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    info_obj = Notifications::AssessmentImportInfo.first
    info_obj.should_not be_nil
    info_obj.last_seq.should eql(1)
  end

  it 'should ignore the design doc and not throw errors' do
    init_misc_docs_with_design_doc
    generate_learner_data
    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    @learner.open_responses[0].answer.should eql(@or_answer)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
  end

  it 'should correctly update the import info with the latest sequence number' do
    init_misc_docs_with_design_doc
    generate_learner_data
    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    Notifications::AssessmentImportInfo.first.last_seq.should eql(4)
  end

  it 'should create a saveable associated with the open response question' do
    generate_learner_data
    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    @learner.open_responses.size.should eql(1)
    @learner.open_responses[0].answers.size.should eql(1)
    @learner.open_responses[0].answer.should eql(@or_answer)
    Notifications::AssessmentImportInfo.first.last_seq.should eql(2)
  end

  it 'should create a saveable associated with the multiple choice question' do
    generate_learner_data
    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    @learner.multiple_choices.size.should eql(1)
    @learner.multiple_choices[0].answers.size.should eql(1)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
  end

  it 'should not create multiple answers when the same learner data is imported twice' do
    generate_learner_data
    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    @learner.multiple_choices.size.should eql(1)
    @learner.multiple_choices[0].answers.size.should eql(1)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
    @learner.open_responses.size.should eql(1)
    @learner.open_responses[0].answers.size.should eql(1)
    @learner.open_responses[0].answer.should eql(@or_answer)

    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    @learner.multiple_choices.size.should eql(1)
    @learner.multiple_choices[0].answers.size.should eql(1)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
    @learner.open_responses.size.should eql(1)
    @learner.open_responses[0].answers.size.should eql(1)
    @learner.open_responses[0].answer.should eql(@or_answer)
  end

  it 'should create multiple answers when changed learner data is imported' do
    generate_learner_data
    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    @learner.multiple_choices.size.should eql(1)
    @learner.multiple_choices[0].answers.size.should eql(1)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
    @learner.open_responses.size.should eql(1)
    @learner.open_responses[0].answers.size.should eql(1)
    @learner.open_responses[0].answer.should eql(@or_answer)

    generate_learner_data
    @importer = Assessments::LearnerDataImporter.new(@couch)
    @importer.run
    @learner.reload
    @learner.multiple_choices.size.should eql(1)
    @learner.multiple_choices[0].answers.size.should eql(2)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
    @learner.open_responses.size.should eql(1)
    @learner.open_responses[0].answers.size.should eql(2)
    @learner.open_responses[0].answer.should eql(@or_answer)
  end

  def generate_learner_data
    Notifications::AssessmentImportInfo.find_or_create_by_database(@couch, :last_seq => 1)
    old_choice = @choice
    while @choice == old_choice
      @choice = rand(3)+1
    end
    uuid_str = UUIDTools::UUID.timestamp_create.to_s

    @or_answer = "This is my answer: #{uuid_str}"
    @mc_answer = @multiple_choice.choices[@choice-1]

    @learner_data = <<DATA
{
   "_id": "31bea50aafabc73aa84e6774b82ecf9d",
   "_rev": "2-da315da23683db0edabcebae8c6296d0",
   "url": "#{@activity.id}/learner/#{@learner.id}",
   "learner": {
       "url": "/learner/#{@learner.id}"
   },
   "activity": {
       "id": "example.df5",
       "rev": "1",
       "url": "#{@activity.id}"
   },
   "pages": [
       {
           "url": "/activity/#{@activity.id}/page/#{@page.id}",
           "steps": [
               {
                   "url": "/activity/#{@activity.id}/page/#{@page.id}/step/#{dom_id_for(@open_response)}",
                   "responseTemplate": {
                       "url": "/activity/#{@activity.id}/response-template/#{dom_id_for(@open_response)}",
                       "values": [
                           "#{@or_answer}"
                       ]
                   }
               },
               {
                   "url": "/activity/#{@activity.id}/page/#{@page.id}/step/#{dom_id_for(@multiple_choice)}",
                   "responseTemplate": {
                       "url": "/activity/#{@activity.id}/response-template/#{dom_id_for(@multiple_choice)}",
                       "values": [
                           #{@choice}
                       ]
                   }
               },
               {
                   "url": "/activity/#{@activity.id}/page/#{@page.id}/step/final-step"
               }
           ]
       }
   ]
}
DATA
  end

  def init_misc_docs
    @changes_doc = <<DOC
{"results":[
{"seq":2,"id":"doc","changes":[{"rev":"rev"}]}
],
"last_seq":2}
DOC
  end

  def init_misc_docs_with_design_doc
    @changes_doc = <<DOC
{"results":[
{"seq":3,"id":"doc","changes":[{"rev":"rev"}]},
{"seq":4,"id":"des","changes":[{"rev":"rev"}]}
],
"last_seq":4}
DOC

   @design_doc = <<DOC
{"_id":"_design/by_url","_rev":"1-0689275b987262c5238e8a46437dad5d","language":"javascript","views":{"url":{"map":"function(doc) { if (doc.url) emit(doc.url, doc);  }"}}}
DOC
  end
end
