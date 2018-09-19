require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

def filter (collection, options = {})
  collection = collection.select { |o| o.is_required } if options[:required]
  collection = collection.select { |o| o.show_in_featured_question_report } if options[:featured]
  collection
end

RSpec::Matchers.define :have_multiple_choice_like do |prompt, options = {}|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    multiple_choices = activity.multiple_choices
    multiple_choices = filter multiple_choices, options
    multiple_choices.map { |m| m.prompt }.detect { |p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_open_response_like do |prompt, options = {}|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    open_responses = activity.open_responses
    open_responses = filter open_responses, options
    open_responses.map { |m| m.prompt }.detect{ |p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_image_question_like do |prompt, options = {}|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    image_questions = activity.image_questions
    image_questions = filter image_questions, options
    image_questions.map{ |m| m.prompt}.detect{|p| p =~ /#{prompt}/i }
  end
end

RSpec::Matchers.define :have_iframe_like do |url, options = {}|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    iframes = activity.iframes
    iframes = filter iframes, options
    iframes = iframes.map{ |m| m.url }.detect{ |u| u =~ /#{url}/i }
    iframes
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

RSpec::Matchers.define :have_page_like do |name,url|
  match do |thing|
    activity = thing.respond_to?(:template) ? thing.template : thing
    pages = activity.pages
    pages.detect{|p| p.name == name &&  p.url == url }
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
  let(:url )        { "http://activity.com/activity/1" }
  let(:page_1_url ) { "http://activity.com/activity/1/pages/5" }
  let(:launch_url)  { "#{url}/1/sessions/"             }
  let(:existing_url){ nil }
  let(:student_report_enabled){true}

  let(:new_hash) do
    {
      "name" => name,
      "url" => url,
      "launch_url" => launch_url,
      "student_report_enabled" => student_report_enabled,
      "description" => 'LARA might still send description, but Portal should ignore it',
      "sections" => [
        {
          "name" => "Cool Activity Section 1",
          "pages" => [
            {
              "name" => "Cool Activity Page 1",
              "url" => page_1_url,
              "elements" => [
                {
                  "type" => "open_response",
                  "id" => "1234568",
                  "prompt" => "Why do you like/dislike this activity?",
                  "is_required" => true,
                  "show_in_featured_question_report" => true
                },
                {
                  "type" => "image_question",
                  "id" => "987654321",
                  "drawing_prompt" => '',
                  "prompt" => "draw a picture of why you love this activity.",
                  "is_required" => true,
                  "show_in_featured_question_report" => true
                },
                {
                  "type" => "image_question",
                  "id" => '5589',
                  "drawing_prompt" => "Really draw a picture",
                  "prompt" => "Now explain the picture you drew",
                  "is_required" => true,
                  "show_in_featured_question_report" => true
                },
                {
                  "type" => "multiple_choice",
                  "id" => "456789",
                  "prompt" => "What color is the sky?",
                  "allow_multiple_selection" => false,
                  "choices" => choice_hash_array,
                  "is_required" => true,
                  "show_in_featured_question_report" => true
                },
                {
                  "type" => "iframe_interactive",
                  "id" => "if_123",
                  "name" => "Test interactive",
                  "url" => "http://test.interactive.com",
                  "display_in_iframe" => true,
                  "native_width" => 400,
                  "native_height" => 500,
                  "is_required" => true,
                  "show_in_featured_question_report" => true
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

  let(:sequence_name)       { "Many fun things" }
  let(:sequence_url)        { "http://activity.com/sequence/1" }
  let(:sequence_author_url) { "#{sequence_url}/edit" }
  let(:sequence_print_url)  { "#{sequence_url}/print" }

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
      "url" => sequence_url,
      "launch_url" => sequence_url,
      "print_url" => sequence_print_url,
      "author_url" => sequence_author_url,
      "activities" => [act2, act1],
      "student_report_enabled" => student_report_enabled
    }
  end

  let(:investigation) do
    FactoryBot.create(:investigation,
                   :user => user
    )
  end

  let(:multiple_choice) { FactoryBot.create(:multiple_choice) }
  let(:open_response)   { FactoryBot.create(:open_response)   }
  let(:image_question)  { FactoryBot.create(:image_question)  }
  let(:iframe)          { FactoryBot.create(:embeddable_iframe)  }

  let(:page) do
    FactoryBot.create(:page,
      :page_elements => [
        FactoryBot.create(:page_element, :embeddable => multiple_choice),
        FactoryBot.create(:page_element, :embeddable => open_response),
        FactoryBot.create(:page_element, :embeddable => image_question),
        FactoryBot.create(:page_element, :embeddable => iframe)
      ]
    )
  end

  let(:section)do
    FactoryBot.create(:section,
      :pages => [page]
    )
  end

  let(:template) do
    FactoryBot.create(:activity,
      :investigation => investigation,
      :sections => [section]
    )
  end

  let(:exist_stubs) do
    {
      :name        => name,
      :url         => existing_url,
      :template    => template
    }
  end

  let(:sequence_template) { FactoryBot.create(:investigation) }

  let(:existing_sequence_stubs) do
    {
      :name => sequence_name,
      :url => sequence_url,
      :template => sequence_template
    }
  end

  let(:existing){ FactoryBot.create(:external_activity, exist_stubs) }

  let(:existing_sequence) { FactoryBot.create(:external_activity, existing_sequence_stubs) }

  let(:existing_locked_sequence) {
    locked_sequence_properties = existing_sequence_stubs
    locked_sequence_properties[:is_locked] = true
    FactoryBot.create(:external_activity, locked_sequence_properties)
  }

  let(:user)    { FactoryBot.create(:user) }


  describe "publish_activity" do

    describe "When publishing a new external activity" do
      it 'should get nil from update_activity' do
        result = ActivityRuntimeAPI.update_activity(new_hash)
        expect(result).to be_nil
      end

      it "should create a new activity" do
        result = ActivityRuntimeAPI.publish_activity(new_hash, user)
        expect(result).not_to be_nil
        expect(result).to have_multiple_choice_like "What color is the sky"
        expect(result).to have_choice_like "blue"
        expect(result.template).to be_a_kind_of(Activity)
        expect(result.template.is_template).to be_truthy
        expect(result).not_to have_choice_like "brown"
        expect(result).to have_image_question_like "draw a picture"
        expect(result).to have_image_question_like "now explain"
        expect(result).to have_iframe_like "http://test.interactive.com"
        expect(result).to have_page_like "Cool Activity Page 1", page_1_url
        # Portal should ignore description
        expect(result.short_description).to be_nil
        expect(result.long_description).to be_nil
        expect(result.long_description_for_teacher).to be_nil
        expect(result.student_report_enabled).to be_truthy
      end

      it "should cause that parent investigation and activities are recognized as templates" do
        result = ActivityRuntimeAPI.publish_activity(new_hash, user)
        expect(result.template.is_template).to be_truthy
        expect(result.template.investigation.is_template).to be_truthy
      end
    end

    describe "When there is an existing external activity with the same url" do
      let(:existing_url) { url }  # the url identifies the existing activity
      let(:student_report_enabled){false}

      describe "when updating an external activity" do
        it "should delete the non-mapped embeddables in the existing activity" do
          existing
          result = ActivityRuntimeAPI.update_activity(new_hash)
          expect(result).not_to be_nil
          expect(result.id).to eq(existing.id)
          expect(result.template.multiple_choices.size).to eq(1)
          expect(result.template.open_responses.size).to eq(1)
          expect(result).to have_open_response_like("dislike this activity")
          expect(result).to have_image_question_like("draw a picture")
        end

        it "should update student_report_enabled if changed" do
          existing
          result = ActivityRuntimeAPI.update_activity(new_hash)
          expect(result).not_to be_nil
          expect(result.student_report_enabled).to be_falsey
        end

        it "should ignore description value" do
          existing
          portal_description = "description set in Portal"
          existing.short_description = portal_description
          existing.long_description = portal_description
          existing.long_description_for_teacher = portal_description
          existing.save!
          result = ActivityRuntimeAPI.update_activity(new_hash)
          expect(result).not_to be_nil
          expect(result.short_description).to eq(portal_description)
          expect(result.long_description).to eq(portal_description)
          expect(result.long_description_for_teacher).to eq(portal_description)
        end
      end

      describe "updating an existing open response" do
        let(:open_response) do
          FactoryBot.create(:open_response,
            :prompt => "the original prompt",  # this will be replaced as the test runs.
            :is_required => false,             # this will be replaced as the test runs.
            :show_in_featured_question_report => false, # this will be replaced as the test runs.
            :external_id => "1234568")
        end

        it "should update the open_response" do
          original_id = open_response.id
          existing
          result = ActivityRuntimeAPI.update_activity(new_hash)
          expect(result.template.open_responses.first.id).to eq(original_id)
          expect(result).to have_open_response_like("dislike this activity", required: true, featured: true)
          expect(result).not_to have_open_response_like("original prompt")
        end
      end

      describe "updating an existing image question" do
        let(:image_question) do
          FactoryBot.create(:image_question,
            :drawing_prompt => '',
            :prompt => "the original prompt",  # this will be replaced as the test runs.
            :is_required => false,             # this will be replaced as the test runs.
            :show_in_featured_question_report => false, # this will be replaced as the test runs.
            :external_id => "987654321")
        end
        it "should update the image_question" do
          original_id = image_question.id
          expect(image_question.external_id).to eq("987654321")
          existing
          result = ActivityRuntimeAPI.publish(new_hash, user)
          expect(result.template.image_questions.first.id).to eq(original_id)
          expect(result).to have_image_question_like("draw a picture", required: true, featured: true)
          expect(result).not_to have_image_question_like("original prompt")
        end
      end

      describe "updating an existing embeddable iframe" do
        let(:iframe) do
          FactoryBot.create(:embeddable_iframe,
            :url => "http://original.url",  # this will be replaced as the test runs.
            :is_required => false,          # this will be replaced as the test runs.
            :show_in_featured_question_report => false, # this will be replaced as the test runs.
            :external_id => "if_123"
          )
        end
        it "should update the iframe" do
          original_id = iframe.id
          expect(iframe.external_id).to eq("if_123")
          existing
          result = ActivityRuntimeAPI.publish(new_hash, user)
          expect(result.template.iframes.first.id).to eq(original_id)
          expect(result).to have_iframe_like("http://test.interactive.com", featured: true, required: true)
          expect(result).not_to have_iframe_like("http://original.url")
        end
      end

      describe "updating an existing multiple choice" do
        let(:choice) do
          FactoryBot.create(:multiple_choice_choice,
            :choice => "this was an original choice",
            :external_id => "232323"
          )
        end
        let(:other_choice) do
          FactoryBot.create(:multiple_choice_choice,
            :choice => "this choice should be deleted",
            :external_id => "something_not_in_the_hash"
          )
        end
        let(:choices) do
          [choice, other_choice]
        end

        let(:multiple_choice) do
          FactoryBot.create(:multiple_choice,
            :prompt => "the original prompt",
            :external_id => "456789",
            :is_required => false,
            :show_in_featured_question_report => false,
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
          expect(@result.template.multiple_choices.first.id).to eq(@original_id)
        end

        it "should have the new prompt, be required and featured" do
          expect(@result).to have_multiple_choice_like("What color is the sky?", required: true, featured: true)
        end

        it "should not have the original choices" do
          expect(@result).not_to have_choice_like("original choice")
          expect(@result).not_to have_choice_like("this choice should be deleted")
        end

        it "should have the new choices" do
          expect(@result).to have_choice_like("red")
          expect(@result).to have_choice_like("blue")
          expect(@result).to have_choice_like("green")
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
            expect(choice.choice).to eq("the content has changed")
            expect(choice.id).to eq(@original_choice_id)
          end

          it "The other choice should be deleted" do
            expect(@result).not_to have_choice_like("this choice should be deleted")
          end

          it "should have the new choices" do
            @result.reload
            expect(@result).to have_choice_like("red")
            expect(@result).to have_choice_like("blue")
            expect(@result).to have_choice_like("green")
            expect(@result).to have_choice_like("the content has changed")
            expect(@result).to have_choice_id choice.id
          end
        end

      end

    end

  end

  describe 'publish_sequence' do
    context 'when publishing a new sequence' do
      let(:result) { ActivityRuntimeAPI.publish_sequence(sequence_hash, user) }

      it 'should create a new external activity' do
        expect(result).not_to be_nil
        expect(result).to be_a_kind_of(ExternalActivity)
        expect(result.url).to eq(sequence_url)
        expect(result.activities.length).to be > 0
        expect(result.name).to eq(sequence_name)
        expect(result.student_report_enabled).to be_truthy
      end
      it 'should create a new investigation' do
        expect(result.template).to be_a_kind_of(Investigation)
        expect(result.template.is_template).to be_truthy
        expect(result.activities.length).to be > 0
      end

      it 'should keep order of activities' do
        expect(result.activities[0].position).to be <= result.activities[1].position
        expect(result.activities[0].name).to eq(sequence_hash['activities'][0]['name'])
        expect(result.activities[1].name).to eq(sequence_hash['activities'][1]['name'])
      end

      it "should cause that parent investigation and activities are recognized as templates" do
        expect(result.template.is_template).to be_truthy
        result.template.activities.map { |a| expect(a.is_template).to be_truthy }
      end
    end

    context 'when updating an existing sequence' do
      let(:sequence_name) { "this is something new"}

      it 'should update the existing investigation details' do
        existing_sequence
        result = ActivityRuntimeAPI.update_sequence(sequence_hash)
        expect(result.id).to eq(existing_sequence.id)
        expect(result.name).to match /something new/
        expect(result.template.name).to match /something new/
        expect(result.author_url).to eq(sequence_author_url)
        expect(result.print_url).to eq(sequence_print_url)
        expect(result.student_report_enabled).to be_truthy
      end

      describe 'student_report_enabled' do
        let(:student_report_enabled){false}

        it 'if set to false in a activity should update the sequence' do
          existing_sequence
          result = ActivityRuntimeAPI.update_sequence(sequence_hash)
          expect(result.student_report_enabled).to be_falsey
        end
      end

      it 'should not override properties that are not provided' do
        existing_locked_sequence
        # the sequence_hash does not provide the is_locked proeprty
        result = ActivityRuntimeAPI.update_sequence(sequence_hash)
        expect(result.is_locked).to eq(true)
      end

      it 'should update order of activities' do
        existing_sequence
        # Swap position of activities.
        sequence_hash['activities'][0], sequence_hash['activities'][1] = sequence_hash['activities'][1], sequence_hash['activities'][0]
        result = ActivityRuntimeAPI.update_sequence(sequence_hash)
        expect(result.activities[0].position).to be <= result.activities[1].position
        expect(result.activities[0].name).to eq(sequence_hash['activities'][0]['name'])
        expect(result.activities[1].name).to eq(sequence_hash['activities'][1]['name'])
      end

      describe 'the report_embeddable_filters' do
        let(:offering)    { mock_model(Portal::Offering)  }
        let(:offerings)   { [offering] }
        let(:mock_filter) { double()   }
        before(:each) do
          allow_any_instance_of(Investigation).to receive(:offerings).and_return(offerings)
          allow_any_instance_of(Activity).to receive(:offerings).and_return(offerings)
          allow(offering).to receive(:report_embeddable_filter).and_return(mock_filter)
        end
       it 'should reset the filters' do
          existing_sequence
          expect(mock_filter).to receive(:clear)
          result = ActivityRuntimeAPI.update_sequence(sequence_hash)
          expect(existing_sequence.template.offerings).to eq(offerings)
        end
      end
    end
  end
end
