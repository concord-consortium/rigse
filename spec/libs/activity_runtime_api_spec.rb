require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper


RSpec::Matchers.define :have_multiple_choice_like do |prompt|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    activity.multiple_choices.map{ |m| m.prompt}.detect{|p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_open_response_like do |prompt|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    activity.open_responses.map{ |m| m.prompt}.detect{|p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_image_question_like do |prompt|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    activity.image_questions.map{ |m| m.prompt}.detect{|p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_choice_like do |choice|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    choices = activity.multiple_choices.map{ |mc| mc.choices}.flatten
    choices.detect{|p| p.choice =~ /#{choice}/i }
  end
end


describe ActivityRuntimeAPI do

  let(:name)        { "Cool Activity"                  }
  let(:description) { name                             }
  let(:url )        { "http://activity.com/activity/1" }
  let(:launch_url)  { "#{url}/1/sessions/"             }
  let(:existing_url){ nil }

  let(:new_hash) do
    {
      "name" => name,
      "description" => description,
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
                  "prompt" => "Why do you like/dislike this activity?"
                },
                {
                  "type" => "image_question",
                  "id" => "987654321",
                  "prompt" => "draw a picture of why you love this activity."
                },
                {
                  "type" => "multiple_choice",
                  "id" => "456789",
                  "prompt" => "What color is the sky?",
                  "allow_multiple_selection" => false,
                  "choices" => [
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
                }
              ]
            }
          ]
        }
      ]
    }
  end

  let (:v2hash) do
    v2hash = new_hash
    v2hash['type'] = 'Activity'
    v2hash
  end

  let (:sequence_name) { "Many fun things" }
  let (:sequence_desc) { "Several activities together in a sequence" }
  let (:sequence_url)  { "http://activity.com/sequence/1" }

  let (:sequence_hash) do
    {
      "type" => "Sequence",
      "name" => sequence_name,
      "description" => sequence_desc,
      "url" => sequence_url,
      "launch_url" => sequence_url,
      "activities" => [v2hash]
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

  let (:sequence_template) { Factory.create(:investigation) }

  let (:existing_sequence_stubs) do
    {
      :name => sequence_name,
      :description => sequence_desc,
      :url => sequence_url,
      :template => sequence_template
    }
  end

  let(:existing){ Factory.create(:external_activity, exist_stubs) }

  let (:existing_sequence) { Factory.create(:external_activity, existing_sequence_stubs) }

  let(:user)    { Factory.create(:user) }


  describe "publish_activity" do

    describe "When publishing a new external activity" do
      it 'should get nil from update_activity' do
        result = ActivityRuntimeAPI.update_activity(new_hash)
        result.should be_nil
      end

      it "should create a new activity" do
        result = ActivityRuntimeAPI.publish_activity(new_hash,user)
        result.should_not be_nil
        result.should have_multiple_choice_like "What color is the sky"
        result.should have_choice_like "blue"
        result.should_not have_choice_like "brown"
        result.should have_image_question_like "draw a picture"
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
            :external_id => "1234568")
        end

        it "should update the open_response" do
          original_id = open_response.id
          existing
          result = ActivityRuntimeAPI.update_activity(new_hash)
          result.template.open_responses.first.id.should == original_id
          result.should have_open_response_like("dislike this activity")
          result.should_not have_open_response_like("original prompt")
        end
      end


      describe "updating an existing image question" do
        let(:image_question) do
          Factory.create(:image_question,
            :prompt => "the original prompt",  # this will be replaced.
            :external_id => "987654321")
        end
        it "should update the image_question" do
          original_id = image_question.id
          image_question.external_id.should == "987654321"
          existing
          result = ActivityRuntimeAPI.publish(new_hash,user)
          result.template.image_questions.first.id == original_id
          result.should have_image_question_like("draw a picture")
          result.should_not have_image_question_like("original prompt")
        end
      end

      describe "updating an existing multiple choice" do
        let(:choice) do
          Factory.create(:multiple_choice_choice,
            :choice => "this was an original choice"
          )
        end

        let(:multiple_choice) do
          Factory.create(:multiple_choice,
            :prompt => "the original prompt",
            :external_id => "456789",
            :choices => [choice]
          )
        end

        before(:each) do
          @original_id = multiple_choice.id
          existing
          @result = ActivityRuntimeAPI.update_activity(new_hash)
        end

        it "should update the existing question" do
          @result.template.multiple_choices.first.id.should == @original_id
        end

        it "should have the new prompt" do
          @result.should have_multiple_choice_like("What color is the sky?")
        end

        it "should not have the original choice" do
          @result.should_not have_choice_like("original choice")
        end

        it "should have the new choices" do
          @result.should have_choice_like("red")
          @result.should have_choice_like("blue")
          @result.should have_choice_like("green")
        end

      end

    end

  end

  describe 'publish_sequence' do
    context 'when publishing a new sequence' do
      it 'should create a new activity' do
        result = ActivityRuntimeAPI.publish_sequence(sequence_hash, user)
        result.should_not be_nil
        result.should be_a_kind_of(ExternalActivity)
        result.url.should == sequence_url
        result.template.should be_a_kind_of(Investigation)
        result.template.activities.length.should > 0
      end
    end

    context 'when updating an existing sequence' do
      it 'should update the existing investigation details' do
        existing_sequence
        result = ActivityRuntimeAPI.update_sequence(sequence_hash)
        result.id.should == existing_sequence.id
      end
    end
  end
end
