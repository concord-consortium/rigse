require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContent do
  def reset_table_index(klass, num)
    ActiveRecord::Base.connection.execute('TRUNCATE ' + klass.table_name)
    ActiveRecord::Base.connection.execute("ALTER TABLE #{klass.table_name} AUTO_INCREMENT = #{num}")
  end

  describe "normal cases" do
    before(:all) do
      @valid_attributes = {
        :id => 1,
        :bundle_logger_id => 1,
        :position => 1,
        :body => "value for body",
        :created_at => Time.now,
        :updated_at => Time.now,
        :otml => "value for otml",
        :processed => false,
        :valid_xml => false,
        :empty => false,
        :uuid => "value for uuid"
      }
      
      @valid_attributes_with_blob = {
        :bundle_logger_id => 1,
        :position => 2,
        :body => '<sessionBundles xmlns:xmi="http://www.omg.org/XMI" xmlns:sailuserdata="sailuserdata" start="2010-10-29T15:34:51.864-0400" stop="2010-10-29T15:37:22.447-0400" curnitUUID="cccccccc-0009-0000-0000-000000000000" sessionUUID="5e1f48bd-2c52-4f13-9383-3fad76590453" lastModified="2010-10-29T15:37:22.510-0400" timeDifference="532" localIP="192.168.1.2">
            <sockParts podId="dddddddd-0002-0000-0000-000000000000" rimName="ot.learner.data" rimShape="[B">
              <sockEntries value="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" millisecondsOffset="150638"/>
            </sockParts>
            <agents role="RUN_WORKGROUP"/>
            <sdsReturnAddresses>http://has.local/dataservice/bundle_loggers/9/bundle_contents.bundle</sdsReturnAddresses>
            <launchProperties key="maven.jnlp.version" value="has-otrunk-0.1.0-20101029.173455"/>
            <launchProperties key="sds_time" value="1288380891864"/>
            <launchProperties key="sailotrunk.otmlurl" value="http://has.local/investigations/7.dynamic_otml"/>
          </sessionBundles>'
      }

      reset_table_index(Embeddable::OpenResponse, 40)
      reset_table_index(Embeddable::MultipleChoiceChoice, 165)
      reset_table_index(Embeddable::ImageQuestion, 25)
      reset_table_index(Dataservice::Blob, 14)
    end
    
    it "should extract saveables into separate model objects" do
      blogger = Dataservice::BundleLogger.create!()
      student = Portal::Student.create!()
      offering = Portal::Offering.create!()
      learner = Portal::Learner.create!(:bundle_logger_id => blogger.id, :student_id => student.id, :offering_id => offering.id)
      mock_rep_learner = mock(Report::Learner, :update_fields => true)
      Report::Learner.should_receive(:for_learner).exactly(4).times.with(learner).and_return(mock_rep_learner,mock_rep_learner,mock_rep_learner,mock_rep_learner)
      learner.bundle_logger = blogger
      learner.save!
      blogger.reload
      learner.reload
      blogger.learner.should_not be_nil
      learner.bundle_logger.should_not be_nil
      @valid_attributes_with_blob[:bundle_logger_id] = blogger.id
      # create open_response with id = 40
      emb = nil
      begin
        emb = Embeddable::OpenResponse.create!(:name => 'open response', :description => 'open response', :prompt => 'open response?', :default_response => '')
      end until emb.id >= 40

      # create multiple_choice_choice with id = 165
      emb = nil
      begin
        emb = Embeddable::MultipleChoiceChoice.create!(:choice => 'someChoice')
      end until emb.id >= 165
      if emb.multiple_choice.nil?
        mc = Embeddable::MultipleChoice.create!(:name => 'mc', :description => 'mc', :prompt => 'mc prompt?', :user_id => 1)
        emb.multiple_choice = mc
        emb.save!
      end

      # create image_question with id = 25,26
      emb = nil
      begin
        emb = Embeddable::ImageQuestion.create!(:user_id => 1, :name => 'image question 25', :prompt => "Please choose an image")
      end until emb.id >= 26
      
      bundle_content = Dataservice::BundleContent.create!(@valid_attributes_with_blob)
      
      # create blob with id = 14,15
      emb = nil
      begin
        emb = Dataservice::Blob.create!(:content => 'image', :bundle_content_id => bundle_content.id)
      end until emb.id >= 15
      
      bundle_content.bundle_logger = blogger
      bundle_content.save!
      bundle_content.reload
      blogger.reload
      bundle_content.bundle_logger_id.should eql(learner.bundle_logger.id)
      bundle_content.bundle_logger.learner.id.should eql(learner.id)
      
      bundle_content.extract_saveables.invoke_job
      
      # 1 open response, 1 multiple choice, 2 image questions
      learner.open_responses.size.should eql(1)
      learner.multiple_choices.size.should eql(1)
      learner.image_questions.size.should eql(2)
      learner.open_responses.each do |saveable|
        saveable.answer.should eql('Jumping jacks with electric sparks')
      end
      learner.multiple_choices.each do |saveable|
        saveable.answers.size.should eql(1)
        saveable.answers[0].answer.should eql('someChoice')
      end
      learner.image_questions.each do |saveable|
        bundle_content.blobs.include?(saveable.answer[:blob]).should be_true
        saveable.answer[:note].should eql('Add a note describing this entry...')
      end
    end
  end

  describe "special cases" do
    before(:all) do
      @valid_attributes_with_multiline_snapshot = {
        :bundle_logger_id => 1,
        :position => 3,
        :body => '<sessionBundles xmlns:xmi="http://www.omg.org/XMI" xmlns:sailuserdata="sailuserdata" start="2012-08-09T14:23:56.274-0700" stop="2012-08-09T14:24:54.683-0700" curnitUUID="cccccccc-0009-0000-0000-000000000000" sessionUUID="d9deebb8-7fb1-4478-93b8-b5d10d0e752e" lastModified="2012-08-09T14:24:54.742-0700" timeDifference="-3045" localIP="192.168.56.1">
            <sockParts podId="dddddddd-0002-0000-0000-000000000000" rimName="ot.learner.data" rimShape="[B">
              <sockEntries value="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" millisecondsOffset="58462"/>
            </sockParts>
            <agents role="RUN_WORKGROUP"/>
            <sdsReturnAddresses>http://portal.local/dataservice/bundle_loggers/9551/bundle_contents.bundle</sdsReturnAddresses>
            <launchProperties key="maven.jnlp.version" value="all-otrunk-snapshot-0.1.0-20120808.210247"/>
            <launchProperties key="sds_time" value="1344547436274"/>
            <launchProperties key="sailotrunk.otmlurl" value="http://portal.local/investigations/1007.dynamic_otml?learner_id=9310"/>
          </sessionBundles>'
      }
      
      reset_table_index(Embeddable::ImageQuestion, 846)
      reset_table_index(Dataservice::Blob, 11896)
    end

    it "should correctly extract multi-line snapshot notes" do
      blogger = Dataservice::BundleLogger.create!()
      student = Portal::Student.create!()
      offering = Portal::Offering.create!()
      learner = Portal::Learner.create!(:bundle_logger_id => blogger.id, :student_id => student.id, :offering_id => offering.id)
      mock_rep_learner = mock(Report::Learner, :update_fields => true)
      Report::Learner.should_receive(:for_learner).exactly(4).times.with(learner).and_return(mock_rep_learner,mock_rep_learner,mock_rep_learner,mock_rep_learner)
      learner.bundle_logger = blogger
      learner.save!
      blogger.reload
      learner.reload
      blogger.learner.should_not be_nil
      learner.bundle_logger.should_not be_nil
      @valid_attributes_with_multiline_snapshot[:bundle_logger_id] = blogger.id
      # create open_response with id = 40
      # create image_question with id = 847

      emb = nil
      begin
        emb = Embeddable::ImageQuestion.create!(:user_id => 1, :name => 'image question 847', :prompt => "Please choose an image")
      end until emb.id >= 847
      
      bundle_content = Dataservice::BundleContent.create!(@valid_attributes_with_multiline_snapshot)
      
      # create blob with id = 11897
      emb = nil
      begin
        emb = Dataservice::Blob.create!(:content => 'image', :bundle_content_id => bundle_content.id)
      end until emb.id >= 11897
      
      bundle_content.bundle_logger = blogger
      bundle_content.save!
      bundle_content.reload
      blogger.reload
      bundle_content.bundle_logger_id.should eql(learner.bundle_logger.id)
      bundle_content.bundle_logger.learner.id.should eql(learner.id)
      
      bundle_content.extract_saveables.invoke_job
      
      learner.image_questions.size.should eql(1)
      learner.image_questions.each do |saveable|
        saveable.answer[:note].should eql('One
Word
Lines
And
It
Is
Nine
Lines
Long')
      end
    end
  end
end
