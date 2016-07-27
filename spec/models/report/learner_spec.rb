require File.expand_path('../../../spec_helper', __FILE__)

include ReportLearnerSpecHelper # defines : saveable_for : answers_for : add_answer

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

    @last_contents   = mock(:updated_at => nil)
    @bucket_contents = mock(:last => @last_contents)
    @bucket_logger   = mock(:bucket_contents => @bucket_contents)

    @learner  = mock_model(Portal::Learner,
      :student  => @student,
      :offering => @offering,
      :bundle_logger => @bundle_logger,
      :periodic_bundle_logger => @periodic_bundle_logger,
      :bucket_logger => @bucket_logger,
      # this is needed because of the inverse_of definition in the report_learner associtation
      # I think newer version of mock_model take care of this for you
      :association => mock(:target= => nil)
    )
  end

  it "should create a valid instance with adequate mocks" do
    @report = Report::Learner.create(:learner => @learner)
  end

  describe "with no bundle_loggers" do
    before(:each) do
      @learner.stub!(:periodic_bundle_logger => nil)
      @bundle_logger.stub!(:last_non_empty_bundle_content => nil)
    end

    it "the last_run time should be nil" do
      report = Report::Learner.create(:learner => @learner)
      report.last_run.should be_nil
    end

    it "the last_run time should be preserved" do
      report = Report::Learner.create(:learner => @learner)
      report.last_run.should be_nil
      now = DateTime.now
      report.last_run = now
      report.calculate_last_run
      report.last_run.should == now
    end
  end

  describe "with only old type bundle loggers" do
    before(:each) do
      @learner.stub!(:periodic_bundle_logger => nil)
      @bundle_content.stub!(:updated_at => Time.now)
    end

    it "should use the last bundle contents update time" do
      report = Report::Learner.create(:learner => @learner)
      report.last_run.should == @bundle_content.updated_at
    end
  end

  describe "with only periodic bundle loggers" do
    before(:each) do
      @learner.stub!(:bundle_logger => nil)
      @periodic_bundle_content.stub!(:updated_at => Time.now)
      @periodic_bundle_logger.stub!(:periodic_bundle_contents => [@periodic_bundle_content])
    end

    it "should use the last bundle contents update time" do
      report = Report::Learner.create(:learner => @learner)
      report.last_run.should == @periodic_bundle_content.updated_at
    end
  end

  describe "with both preiodic and standard loggers" do
    describe "when the periodic logger is the most recent" do
      before(:each) do
        @bundle_content.stub!(:updated_at => Time.now - 2.hours)
        @bundle_logger.stub!(:last_non_empty_bundle_content => @bundle_content)
        @periodic_bundle_content.stub!(:updated_at => Time.now)
        @periodic_bundle_logger.stub!(:periodic_bundle_contents => [@periodic_bundle_content])
      end

      it "should use the periodic update time" do
        report = Report::Learner.create(:learner => @learner)
        report.last_run.should == @periodic_bundle_content.updated_at
      end
    end
    describe "when the periodic logger is the most recent" do
      before(:each) do
        @bundle_content.stub!(:updated_at => Time.now)
        @bundle_logger.stub!(:last_non_empty_bundle_content => @bundle_content)

        @periodic_bundle_content.stub!(:updated_at => Time.now - 2.hours)
        @periodic_bundle_logger.stub!(:periodic_bundle_contents => [@periodic_bundle_content])
      end

      it "should use the bundle update time" do
        report = Report::Learner.create(:learner => @learner)
        report.last_run.should == @bundle_content.updated_at
      end
    end

  end

  describe "feedback in reports" do
    let(:learner)          { FactoryGirl.create(:full_portal_learner) }
    let(:report_learner)   { learner.report_learner }
    let(:offering)         { learner.offering       }

    describe "basic test setup" do
      subject {report_learner}
      it { should_not be_nil}

      describe "answers" do
        subject { report_learner.answers }
        it { should_not be_nil}
      end
      describe "offering" do
        subject { offering }
        it { should_not be_nil}
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
        Investigation.any_instance.stub(:reportable_elements).and_return( embeddables.map { |e| {embeddable: e} } )
      end

      it { should have(0).answers }

      describe "when the learner answers something thing" do
        before(:each) do
          add_answer(open_response, {answer: "testing"}           )
          add_answer(image_question, {blob: Dataservice::Blob.create(), note: "note"} )
          report_learner.update_answers()
        end
        its(:answers) { should have(2).answers }

        describe "the feedback" do
          it "should have feedback entries for each answer" do
            subject.answers.each do |answer|
              qkey,a = answer
              a[:feedbacks].should_not be_nil
            end
          end

          it "should indicate that the answers need feedback" do
            subject.answers.each do |answer|
              qkey,a = answer
              a[:needs_review].should be_true
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
              open_response_saveable[1][:needs_review].should be_false
            end

            describe "adding a new answer" do
              before(:each) do
                add_answer(open_response, {answer: "testing again"})
                report_learner.update_answers()
              end

              it "should require feedback because there is a new answer" do
                open_response_saveable[1][:needs_review].should be_true
              end
            end

          end
        end
      end
    end



  end

end
