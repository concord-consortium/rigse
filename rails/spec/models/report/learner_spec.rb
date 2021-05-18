require File.expand_path('../../../spec_helper', __FILE__)

include ReportLearnerSpecHelper # defines : saveable_for : answers_for : add_answer : stub_all_reportables

describe Report::Learner do
  before(:each) do
    @user     = mock_model(User,
      :name => "joe"
    )

    @student  = mock_model(Portal::Student,
      :user => @user,
      :permission_forms => []
    )

    @runnable = mock_model(Activity,
      :reportable_elements => [],
      :page_elements => []
    )

    @class    = mock_model(Portal::Clazz,
      :school   => mock_model(Portal::School, :name => "my school"),
      :teachers => []
    )

    @offering = mock_model(Portal::Offering,
      :runnable => @runnable,
      :clazz    => @class,
      :name     => "offering",
      :internal_report? => true,
      :report_embeddable_filter => nil,
      :reload => nil
    )

    @bundle_content = mock_model(Dataservice::BundleContent)

    @bundle_logger = mock_model(Dataservice::BundleLogger,
      :last_non_empty_bundle_content => @bundle_content
    )

    @periodic_bundle_content = mock_model(Dataservice::PeriodicBundleContent)

    @periodic_bundle_logger = mock_model(Dataservice::PeriodicBundleLogger,
      :periodic_bundle_contents => [@periodic_bundle_content]
    )

    @last_contents   = double('last_contents', :updated_at => nil)
    @bucket_contents = double('bucket_contents', :last => @last_contents)
    @bucket_logger   = double('bucket_logger', :bucket_contents => @bucket_contents)

    @learner  = mock_model(Portal::Learner,
      :student  => @student,
      :offering => @offering,
      :bundle_logger => @bundle_logger,
      :periodic_bundle_logger => @periodic_bundle_logger,
      :bucket_logger => @bucket_logger
    )
  end

  it "should create a valid instance with adequate mocks" do
    @report = Report::Learner.create(:learner => @learner)
  end

  describe "with no bundle_loggers" do
    before(:each) do
      allow(@learner).to receive_messages(:periodic_bundle_logger => nil)
      allow(@bundle_logger).to receive_messages(:last_non_empty_bundle_content => nil)
    end

    it "the last_run time should be nil" do
      report = Report::Learner.create(:learner => @learner)
      expect(report.last_run).to be_nil
    end

    it "the last_run time should be preserved" do
      report = Report::Learner.create(:learner => @learner)
      expect(report.last_run).to be_nil
      now = DateTime.now
      report.last_run = now
      report.calculate_last_run
      expect(report.last_run).to eq(now)
    end
  end

  describe "with only old type bundle loggers" do
    before(:each) do
      allow(@learner).to receive_messages(:periodic_bundle_logger => nil)
      allow(@bundle_content).to receive_messages(:updated_at => Time.now)
    end

    it "should use the last bundle contents update time" do
      report = Report::Learner.create(:learner => @learner)
      expect(report.last_run).to eq(@bundle_content.updated_at.change(:usec => 0))
    end
  end

  describe "with only periodic bundle loggers" do
    before(:each) do
      allow(@learner).to receive_messages(:bundle_logger => nil)
      allow(@periodic_bundle_content).to receive_messages(:updated_at => Time.now)
      allow(@periodic_bundle_logger).to receive_messages(:periodic_bundle_contents => [@periodic_bundle_content])
    end

    it "should use the last bundle contents update time" do
      report = Report::Learner.create(:learner => @learner)
      expect(report.last_run).to eq(@periodic_bundle_content.updated_at.change(:usec => 0))
    end
  end

  describe "with both preiodic and standard loggers" do
    describe "when the periodic logger is the most recent" do
      before(:each) do
        allow(@bundle_content).to receive_messages(:updated_at => Time.now - 2.hours)
        allow(@bundle_logger).to receive_messages(:last_non_empty_bundle_content => @bundle_content)
        allow(@periodic_bundle_content).to receive_messages(:updated_at => Time.now)
        allow(@periodic_bundle_logger).to receive_messages(:periodic_bundle_contents => [@periodic_bundle_content])
      end

      it "should use the periodic update time" do
        report = Report::Learner.create(:learner => @learner)
        expect(report.last_run).to eq(@periodic_bundle_content.updated_at.change(:usec => 0))
      end
    end
    describe "when the periodic logger is the most recent" do
      before(:each) do
        allow(@bundle_content).to receive_messages(:updated_at => Time.now)
        allow(@bundle_logger).to receive_messages(:last_non_empty_bundle_content => @bundle_content)

        allow(@periodic_bundle_content).to receive_messages(:updated_at => Time.now - 2.hours)
        allow(@periodic_bundle_logger).to receive_messages(:periodic_bundle_contents => [@periodic_bundle_content])
      end

      it "should use the bundle update time" do
        report = Report::Learner.create(:learner => @learner)
        expect(report.last_run).to eq(@bundle_content.updated_at.change(:usec => 0))
      end
    end

  end

  describe "feedback in reports" do
    let(:learner)          { FactoryBot.create(:full_portal_learner) }
    let(:report_learner)   { learner.report_learner }
    let(:offering)         { learner.offering       }

    describe "basic test setup" do
      subject {report_learner}
      it { is_expected.not_to be_nil}

      describe "answers" do
        subject { report_learner.answers }
        it { is_expected.not_to be_nil}
      end
      describe "offering" do
        subject { offering }
        it { is_expected.not_to be_nil}
      end
    end


    # We are stubbing #reportables in the runnable to avoids crazy structure of pages / &etc.
    # TODO: Its a bit hacky, but it should works for now, and be clearer than the alternatives.
    describe "after adding some answers and running update on the report learner" do
      let(:multiple_choice) { FactoryBot.create(:multiple_choice) }
      let(:open_response)   { FactoryBot.create(:open_response)   }
      let(:image_question)  { FactoryBot.create(:image_question)  }
      let(:embeddables)     { [ multiple_choice, open_response, image_question ] }
      let(:learner_answers) { report_learner }

      subject { report_learner}
      before(:each) do
        # Investigation.any_instance.stub(:reportable_elements).and_return( embeddables.map { |e| {embeddable: e} } )
        stub_all_reportables(Investigation, embeddables)
      end

      it 'has no answers' do
        expect(subject.answers.size).to eq(0)
      end

      describe "when the learner answers something" do
        before(:each) do
          add_answer(open_response, {answer: "testing"}           )
          add_answer(image_question, {blob: Dataservice::Blob.create(), note: "note"} )
          report_learner.update_answers()
        end

        it 'has 2 answers' do
          expect(subject.answers.size).to eq(2)
        end

        describe "the feedback" do
          it "should have feedback entries for each answer" do
            subject.answers.each do |answer|
              qkey,a = answer
              expect(a[:feedbacks]).not_to be_nil
            end
          end

          describe "giving feedback" do
            let(:last_answer)           { learner.answers.last }
            let(:feedback)              {{ feedback: "great job!", score: 4, has_been_reviewed: true}}
            let(:open_response_saveable) do
              subject.answers.detect { |k,v| k == "#{open_response.class.to_s}|#{open_response.id}"}
            end
            before(:each) do
              answers_for(open_response).last.update(feedback)
              report_learner.update_answers()
            end

            it "should no longer require feedback for the open response item" do
              expect(open_response_saveable[1][:needs_review]).to be_falsey
            end

            describe "adding a new answer" do
              before(:each) do
                add_answer(open_response, {answer: "testing again"})
                report_learner.update_answers()
              end

            end

          end
        end
      end
    end



  end

  describe "with_permission_ids" do
    let(:permission_form_a) { FactoryBot.create(:permission_form) }

    let(:permission_form_b) { FactoryBot.create(:permission_form) }

    let(:offering) { FactoryBot.create(:portal_offering) }

    let(:report_learner_a) do
      student = FactoryBot.create(:full_portal_student,
        permission_forms: [permission_form_a]
      )

      learner = FactoryBot.create(:portal_learner,
        offering: offering,
        student: student)

      Report::Learner.create(:learner => learner)
    end

    let(:report_learner_b) do
      student = FactoryBot.create(:full_portal_student,
        permission_forms: [permission_form_b]
      )

      learner = FactoryBot.create(:portal_learner,
        offering: offering,
        student: student)

      Report::Learner.create(:learner => learner)
    end

    it "should not return a learner without the permission_id" do
      report_learner_a
      expect(Report::Learner.with_permission_ids([99999]).count).to eq(0)
    end

    it "should return a learner with with the correct permission_id" do
      report_learner_a
      report_learner_b
      expect(Report::Learner.with_permission_ids([permission_form_a.id]).count).to eq(1)
    end

  end


  # TODO: auto-generated
  describe '.after' do # scope test
    it 'supports named scope after' do
      expect(described_class.limit(3).after(Date.current)).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.before' do # scope test
    it 'supports named scope before' do
      expect(described_class.limit(3).before(Date.current)).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.in_schools' do # scope test
    it 'supports named scope in_schools' do
      expect(described_class.limit(3).in_schools([1])).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.in_classes' do # scope test
    it 'supports named scope in_classes' do
      expect(described_class.limit(3).in_classes([1])).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.with_permission_ids' do # scope test
    it 'supports named scope with_permission_ids' do
      expect(described_class.limit(3).with_permission_ids([1])).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.with_runnables' do # scope test
    it 'supports named scope with_runnables' do
      expect(described_class.limit(3).with_runnables([User.new])).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#ensure_no_nils' do
    it 'ensure_no_nils' do
      learner = described_class.new
      result = learner.ensure_no_nils

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#serialize_blob_answer' do
    it 'serialize_blob_answer' do
      learner = described_class.new
      answer = double('answer')
      result = learner.serialize_blob_answer(answer)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#last_run_string' do
    it 'last_run_string' do
      learner = described_class.new
      opts = {}
      result = learner.last_run_string(opts)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.build_last_run_string' do
    it 'build_last_run_string' do
      last_run = Time.now
      opts = {}
      result = described_class.build_last_run_string(last_run, opts)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#calculate_last_run' do
    xit 'calculate_last_run' do
      learner = described_class.new
      result = learner.calculate_last_run

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_answers' do
    xit 'update_answers' do
      learner = described_class.new
      result = learner.update_answers

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.encode_answer_key' do
    it 'encode_answer_key' do
      item = described_class.new
      result = described_class.encode_answer_key(item)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.decode_answer_key' do
    it 'decode_answer_key' do
      answer_key = 'abc'
      result = described_class.decode_answer_key(answer_key)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_field' do
    it 'update_field' do
      learner = described_class.new
      methods_string = 'methods_string'
      field = double('field')
      result = learner.update_field(methods_string, field) { |value| }

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_fields' do
    xit 'update_fields' do
      learner = described_class.new
      result = learner.update_fields

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#escape_comma' do
    it 'escape_comma' do
      learner = described_class.new
      string = 'string'
      result = learner.escape_comma(string)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_teacher_info_fields' do
    it 'update_teacher_info_fields' do
      learner = described_class.new
      result = learner.update_teacher_info_fields

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_permission_forms' do
    it 'update_permission_forms' do
      learner = described_class.new
      result = learner.update_permission_forms

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_activity_completion_status' do
    xit 'update_activity_completion_status' do
      learner = described_class.new
      report_util = double('report_util')
      result = learner.update_activity_completion_status(report_util)

      expect(result).not_to be_nil
    end
  end


end
