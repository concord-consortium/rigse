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

    @last_contents   = double(:updated_at => nil)
    @bucket_contents = double(:last => @last_contents)
    @bucket_logger   = double(:bucket_contents => @bucket_contents)

    @learner  = mock_model(Portal::Learner,
      :student  => @student,
      :offering => @offering,
      :bundle_logger => @bundle_logger,
      :periodic_bundle_logger => @periodic_bundle_logger,
      :bucket_logger => @bucket_logger,
      # this is needed because of the inverse_of definition in the report_learner associtation
      # I think newer version of mock_model take care of this for you
      :association => double(:target= => nil)
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
      expect(report.last_run).to eq(@bundle_content.updated_at)
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
      expect(report.last_run).to eq(@periodic_bundle_content.updated_at)
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
        expect(report.last_run).to eq(@periodic_bundle_content.updated_at)
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
        expect(report.last_run).to eq(@bundle_content.updated_at)
      end
    end

  end

  describe "feedback in reports" do
    let(:learner)          { FactoryGirl.create(:full_portal_learner) }
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
      let(:multiple_choice) { FactoryGirl.create(:multiple_choice) }
      let(:open_response)   { FactoryGirl.create(:open_response)   }
      let(:image_question)  { FactoryGirl.create(:image_question)  }
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
              answers_for(open_response).last.update_attributes(feedback)
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
    let(:permission_form_a) { FactoryGirl.create(:permission_form) }

    let(:permission_form_b) { FactoryGirl.create(:permission_form) }

    let(:offering) { FactoryGirl.create(:portal_offering) }

    let(:report_learner_a) do
      student = FactoryGirl.create(:full_portal_student,
        permission_forms: [permission_form_a]
      )

      learner = FactoryGirl.create(:portal_learner,
        offering: offering,
        student: student)

      Report::Learner.create(:learner => learner)
    end

    let(:report_learner_b) do
      student = FactoryGirl.create(:full_portal_student,
        permission_forms: [permission_form_b]
      )

      learner = FactoryGirl.create(:portal_learner,
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

end
