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

    couch = "http://localhost/db/assessments"
    @changes_uri = URI.parse("#{couch}/_changes")
    @doc_uri = URI.parse("#{couch}/doc?rev=rev")
    get_changes_doc
    OpenURI.should_receive(:open_uri) {|uri,opts|
      out = '{"results":[], "last_seq":1}'
      if uri == @changes_uri
        out = @changes_doc
      elsif uri == @doc_uri
        out = @learner_data
      end
      out
    }.at_least(:once)

    @importer = Assessments::LearnerDataImporter.new(couch)
  end

  it 'should work' do
    true.should be_true
  end

  it 'should create a saveable associated with the open response question' do
    generate_learner_data
    @importer.run
    @learner.open_responses.size.should eql(1)
    @learner.open_responses[0].answers.size.should eql(1)
    @learner.open_responses[0].answer.should eql(@or_answer)
  end

  it 'should create a saveable associated with the multiple choice question' do
    generate_learner_data
    @importer.run
    @learner.multiple_choices.size.should eql(1)
    @learner.multiple_choices[0].answers.size.should eql(1)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
  end

  it 'should not create multiple answers when the same learner data is imported twice' do
    generate_learner_data
    @importer.run
    @learner.multiple_choices.size.should eql(1)
    @learner.multiple_choices[0].answers.size.should eql(1)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
    @learner.open_responses.size.should eql(1)
    @learner.open_responses[0].answers.size.should eql(1)
    @learner.open_responses[0].answer.should eql(@or_answer)

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
    @importer.run
    @learner.multiple_choices.size.should eql(1)
    @learner.multiple_choices[0].answers.size.should eql(1)
    @learner.multiple_choices[0].choice.should eql(@mc_answer)
    @learner.open_responses.size.should eql(1)
    @learner.open_responses[0].answers.size.should eql(1)
    @learner.open_responses[0].answer.should eql(@or_answer)

    generate_learner_data
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

  def get_changes_doc
    @changes_doc = <<DOC
{"results":[
{"seq":1,"id":"doc","changes":[{"rev":"rev"}]}
],
"last_seq":1}
DOC
  end
end
