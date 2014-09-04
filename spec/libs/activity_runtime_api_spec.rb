require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper


RSpec::Matchers.define :have_multiple_choice_like do |prompt, options = {}|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    multiple_choices = activity.multiple_choices
    multiple_choices = multiple_choices.select { |m| m.is_required } if options[:required]
    multiple_choices.map { |m| m.prompt }.detect { |p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_open_response_like do |prompt, options = {}|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    open_responses = activity.open_responses
    open_responses = open_responses.select { |m| m.is_required } if options[:required]
    open_responses.map { |m| m.prompt }.detect{ |p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_image_question_like do |prompt, options = {}|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    image_questions = activity.image_questions
    image_questions = image_questions.select { |m| m.is_required } if options[:required]
    image_questions.map{ |m| m.prompt}.detect{|p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_choice_like do |choice|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    choices = activity.multiple_choices.map{ |mc| mc.choices}.flatten
    choices.detect{|p| p.choice =~ /#{choice}/i }
  end
end

RSpec::Matchers.define :have_choice_id do |choice_id|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    choices = activity.multiple_choices.map{ |mc| mc.choice_ids}.flatten
    choices.detect{|p| p == choice_id }
  end
end


describe ActivityRuntimeAPI do
  include SolrSpecHelper

  before(:all) do
    solr_setup
    clean_solar_index
  end

  after(:all) do
    clean_solar_index
  end

  let(:name)        { "Cool Activity"                  }
  let(:description) { name                             }
  let(:abstract)    { "abstract"                       }
  let(:url )        { "http://activity.com/activity/1" }
  let(:launch_url)  { "#{url}/1/sessions/"             }
  let(:existing_url){ nil }

  let(:new_hash) do
    {
      "name" => name,
      "description" => description,
      "abstract"    => abstract,
      "url" => url,
      "launch_url" => launch_url,
      "sections" => [
        {
          "name" => "Cool Activity Section 1",
          "pages" => [
            {
              "name" => "Cool Activity Page 1",
              "elements" => [
                {
                  "type" => "open_response",
                  "id" => "1234568",
                  "prompt" => "Why do you like/dislike this activity?",
                  "is_required" => true
                },
                {
                  "type" => "image_question",
                  "id" => "987654321",
                  "drawing_prompt" => '',
                  "prompt" => "draw a picture of why you love this activity.",
                  "is_required" => true
                },
                {
                  "type" => "image_question",
                  "id" => '5589',
                  "drawing_prompt" => "Really draw a picture",
                  "prompt" => "Now explain the picture you drew",
                  "is_required" => true
                },
                {
                  "type" => "multiple_choice",
                  "id" => "456789",
                  "prompt" => "What color is the sky?",
                  "allow_multiple_selection" => false,
                  "choices" => choice_hash_array,
                  "is_required" => true
                }
              ]
            }
          ]
        }
      ]
    }
  end
  let(:choice_hash_array) do
    [
      {
        "id" => "97",
        "content" => "red"
      },
      {
        "id" => "98",
        "content" => "blue",
        "correct" => true
      },
      {
        "id" => "99",
        "content" => "greenish-green"
      }
    ]
  end

  let(:sequence_name)     { "Many fun things" }
  let(:sequence_desc)     { "Several activities together in a sequence" }
  let(:sequence_abstract) { abstract }
  let(:sequence_url)      { "http://activity.com/sequence/1" }

  let(:sequence_hash) do
    act1 = new_hash.clone
    act1['name'] = 'Cool Activity 1'
    act1['type'] = 'Activity'
    act2 = new_hash.clone
    act2['name'] = 'Cool Activity 2'
    act2['type'] = 'Activity'
    {
      "type" => "Sequence",
      "name" => sequence_name,
      "description" => sequence_desc,
      "abstract" => sequence_abstract,
      "url" => sequence_url,
      "launch_url" => sequence_url,
      "activities" => [act2, act1]
    }
  end

  let(:investigation) do
    Factory.create(:investigation,
      :user => user
    )
  end

  let(:multiple_choice) { Factory.create(:multiple_choice) }
  let(:open_response)   { Factory.create(:open_response)   }
  let(:image_question)  { Factory.create(:image_question)  }

  let(:page) do
    Factory.create(:page,
      :page_elements => [
        Factory.create(:page_element, :embeddable => multiple_choice),
        Factory.create(:page_element, :embeddable => open_response),
        Factory.create(:page_element, :embeddable => image_question)
      ]
    )
  end

  let(:section)do
    Factory.create(:section,
      :pages => [page]
    )
  end

  let(:template) do
    Factory.create(:activity,
      :investigation => investigation,
      :sections => [section]
    )
  end

  let(:exist_stubs) do
    {
      :name        => name,
      :description => description,
      :url         => existing_url,
      :template    => template
    }
  end

  let(:sequence_template) { Factory.create(:investigation) }

  let(:existing_sequence_stubs) do
    {
      :name => sequence_name,
      :description => sequence_desc,
      :url => sequence_url,
      :template => sequence_template
    }
  end

  let(:existing){ Factory.create(:external_activity, exist_stubs) }

  let(:existing_sequence) { Factory.create(:external_activity, existing_sequence_stubs) }

  let(:user)    { Factory.create(:user) }


  describe "publish_activity" do

    describe "When publishing a new external activity" do
      it 'should get nil from update_activity' do
        result = ActivityRuntimeAPI.update_activity(new_hash)
        result.should be_nil
      end

      it "should create a new activity" do
        result = ActivityRuntimeAPI.publish_activity(new_hash, user)
        result.should_not be_nil
        result.should have_multiple_choice_like "What color is the sky"
        result.should have_choice_like "blue"
        result.template.should be_a_kind_of(Activity)
        result.template.is_template.should be_true
        result.should_not have_choice_like "brown"
        result.should have_image_question_like "draw a picture"
        result.should have_image_question_like "now explain"
      end

      it "should cause that parent investigation and activities are recognized as templates" do
        result = ActivityRuntimeAPI.publish_activity(new_hash, user)
        result.template.is_template.should be_true
        result.template.investigation.is_template.should be_true
      end

      it "should cause that parent investigation and activities are indexed in SOLR as templates" do
        result = ActivityRuntimeAPI.publish_activity(new_hash, user)
        Activity.search {
          with :name, result.template.name
          with :is_template, true
        }.results.size.should == 1
        Investigation.search {
          with :name, result.template.investigation.name
          with :is_template, true
        }.results.size.should == 1
      end
    end

    describe "When there is an existing external activity with the same url" do
      let(:existing_url) { url }  # the url identifies the existing activity

      describe "when updating an external activity" do
        it "should delete the non-mapped embeddables in the existing activity" do
          existing
          result = ActivityRuntimeAPI.update_activity(new_hash)
          result.should_not be_nil
          result.id.should == existing.id
          result.template.multiple_choices.should have(1).question
          result.template.open_responses.should have(1).question
          result.should have_open_response_like("dislike this activity")
          result.should have_image_question_like("draw a picture")
        end
      end

      describe "updating an existing open response" do
        let(:open_response) do
          Factory.create(:open_response,
            :prompt => "the original prompt",  # this will be replaced.
            :is_required => false,             # this will be replaced.
            :external_id => "1234568")
        end

        it "should update the open_response" do
          original_id = open_response.id
          existing
          result = ActivityRuntimeAPI.update_activity(new_hash)
          result.template.open_responses.first.id.should == original_id
          result.should have_open_response_like("dislike this activity", required: true)
          result.should_not have_open_response_like("original prompt")
        end
      end


      describe "updating an existing image question" do
        let(:image_question) do
          Factory.create(:image_question,
            :drawing_prompt => '',
            :prompt => "the original prompt",  # this will be replaced.
            :is_required => false,             # this will be replaced.
            :external_id => "987654321")
        end
        it "should update the image_question" do
          original_id = image_question.id
          image_question.external_id.should == "987654321"
          existing
          result = ActivityRuntimeAPI.publish(new_hash, user)
          result.template.image_questions.first.id.should == original_id
          result.should have_image_question_like("draw a picture", required: true)
          result.should_not have_image_question_like("original prompt")
        end
      end

      describe "updating an existing multiple choice" do
        let(:choice) do
          Factory.create(:multiple_choice_choice,
            :choice => "this was an original choice",
            :external_id => "232323"
          )
        end
        let(:other_choice) do
          Factory.create(:multiple_choice_choice,
            :choice => "this choice should be deleted",
            :external_id => "something_not_in_the_hash"
          )
        end
        let(:choices) do
          [choice, other_choice]
        end

        let(:multiple_choice) do
          Factory.create(:multiple_choice,
            :prompt => "the original prompt",
            :external_id => "456789",
            :is_required => false,
            :choices => choices
          )
        end

        before(:each) do
          @original_id = multiple_choice.id
          existing
          @original_choice_id = choice.id
          @result = ActivityRuntimeAPI.update_activity(new_hash)
        end

        it "should update the existing question" do
          @result.template.multiple_choices.first.id.should == @original_id
        end

        it "should have the new prompt and be required" do
          @result.should have_multiple_choice_like("What color is the sky?", required: true)
        end

        it "should not have the original choices" do
          @result.should_not have_choice_like("original choice")
          @result.should_not have_choice_like("this choice should be deleted")
        end

        it "should have the new choices" do
          @result.should have_choice_like("red")
          @result.should have_choice_like("blue")
          @result.should have_choice_like("green")
        end

        describe "updating choices that exist" do
          let(:choice_hash_array) do
            [
              {
                "id" => "97",
                "content" => "red"
              },
              {
                "id" => "98",
                "content" => "blue",
                "correct" => true
              },
              {
                "id" => "99",
                "content" => "greenish-green"
              },
              {
                "id" => "232323",
                "content" => "the content has changed"
              }
            ]
          end

          it "The original choice should be updated" do
            choice.reload
            choice.choice.should == "the content has changed"
            choice.id.should == @original_choice_id
          end

          it "The other choice should be deleted" do
            @result.should_not have_choice_like("this choice should be deleted")
          end

          it "should have the new choices" do
            @result.reload
            @result.should have_choice_like("red")
            @result.should have_choice_like("blue")
            @result.should have_choice_like("green")
            @result.should have_choice_like("the content has changed")
            @result.should have_choice_id choice.id
          end
        end

      end

    end

  end

  describe 'publish_sequence' do
    context 'when publishing a new sequence' do
      let(:result) { ActivityRuntimeAPI.publish_sequence(sequence_hash, user) }

      it 'should create a new external activity' do
        result.should_not be_nil
        result.should be_a_kind_of(ExternalActivity)
        result.url.should == sequence_url
        result.activities.length.should > 0
        result.name.should == sequence_name
        result.description.should == sequence_desc
        result.abstract.should == sequence_abstract
      end
      it 'should create a new investigation' do
        result.template.should be_a_kind_of(Investigation)
        result.template.is_template.should be_true
        result.template.description.should == sequence_desc
        result.template.abstract.should == sequence_abstract
        result.activities.length.should > 0
      end

      it 'should keep order of activities' do
        result.activities[0].position.should <= result.activities[1].position
        result.activities[0].name.should == sequence_hash['activities'][0]['name']
        result.activities[1].name.should == sequence_hash['activities'][1]['name']
      end

      it "should cause that parent investigation and activities are recognized as templates" do
        result.template.is_template.should be_true
        result.template.activities.map { |a| a.is_template.should be_true }
      end

      it "should cause that parent investigation and activities are indexed in SOLR as templates" do
        Investigation.search {
          with :name, result.template.name
          with :is_template, true
        }.results.size.should == 1
        Activity.search {
          with :name, result.template.activities.map { |a| a.name }
          with :is_template, true
        }.results.size.should == 2
      end
    end

    context 'when updating an existing sequence' do
      let(:sequence_abstract) { "this is something new"}
      it 'should update the existing investigation details' do
        existing_sequence
        result = ActivityRuntimeAPI.update_sequence(sequence_hash)
        result.id.should == existing_sequence.id
        result.abstract.should match /something new/
        result.template.abstract.should match /something new/
      end

      it 'should update order of activities' do
        existing_sequence
        # Swap position of activities.
        sequence_hash['activities'][0], sequence_hash['activities'][1] = sequence_hash['activities'][1], sequence_hash['activities'][0]
        result = ActivityRuntimeAPI.update_sequence(sequence_hash)
        result.activities[0].position.should <= result.activities[1].position
        result.activities[0].name.should == sequence_hash['activities'][0]['name']
        result.activities[1].name.should == sequence_hash['activities'][1]['name']
      end

      describe 'the report_embeddable_filters' do
        let(:offering)    { mock_model(Portal::Offering)  }
        let(:offerings)   { [offering] }
        let(:mock_filter) { double()   }
        before(:each) do
          Investigation.any_instance.stub(:offerings).and_return(offerings)
          Activity.any_instance.stub(:offerings).and_return(offerings)
          offering.stub!(:report_embeddable_filter).and_return(mock_filter)
        end
       it 'should reset the filters' do
          existing_sequence
          mock_filter.should_receive(:clear)
          result = ActivityRuntimeAPI.update_sequence(sequence_hash)
          existing_sequence.template.offerings.should == offerings
        end
      end
    end
  end
end
