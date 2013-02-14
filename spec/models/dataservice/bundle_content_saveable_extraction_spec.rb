require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContent do
  def reset_table_index(klass, num)
    ActiveRecord::Base.connection.execute('TRUNCATE ' + klass.table_name)
    ActiveRecord::Base.connection.execute("ALTER TABLE #{klass.table_name} AUTO_INCREMENT = #{num}")
  end

  def restart_transaction
    ActiveRecord::Base.connection.execute("START TRANSACTION")
    ActiveRecord::Base.connection.execute("SAVEPOINT active_record_1")
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
      offering.runnable = Investigation.create!(:name => "Test Investigation")
      offering.save
      # mock_rep_learner = mock(Report::Learner, :update_fields => true)
      # Portal::Learner.should_receive(:create_report_learner).and_return(mock_rep_learner)
      learner = Portal::Learner.create!(:bundle_logger_id => blogger.id, :student_id => student.id, :offering_id => offering.id)
      # learner.should_receive(:report_learner).and_return(mock_rep_learner)
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

      # 1 open response, 1 multiple choice, 2 image questions
      learner.open_responses.size.should eql(1)
      learner.multiple_choices.size.should eql(1)
      learner.image_questions.size.should eql(2)
      learner.open_responses.each do |saveable|
        saveable.answer.should eql('Jumping jacks with electric sparks')
      end
      learner.multiple_choices.each do |saveable|
        saveable.answers.size.should eql(1)
        saveable.answers[0].answer.should eql([{:answer => 'someChoice', :correct => nil}])
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

      @valid_attributes_with_multiple_select_and_rationale = {
        :bundle_logger_id => 1,
        :position => 4,
        :body => '<sessionBundles xmlns:xmi="http://www.omg.org/XMI" xmlns:sailuserdata="sailuserdata" start="2013-01-16T10:05:30.250-0800" stop="2013-01-16T10:08:18.613-0800" curnitUUID="cccccccc-0009-0000-0000-000000000000" sessionUUID="e7a37d7c-07cc-4242-84c8-957c257c81fc" lastModified="2013-01-16T10:08:18.640-0800" timeDifference="-2122" localIP="192.168.56.1">
            <sockParts podId="dddddddd-0002-0000-0000-000000000000" rimName="ot.learner.data" rimShape="[B">
              <sockEntries value="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" millisecondsOffset="168389"/>
            </sockParts>
            <agents role="RUN_WORKGROUP"/>
            <sdsReturnAddresses>http://portal.local/dataservice/bundle_loggers/9549/bundle_contents.bundle</sdsReturnAddresses>
            <launchProperties key="previous.bundle.session.id" value="d85564c7-25b9-4f61-90d6-b50fe6f31dbf"/>
            <launchProperties key="maven.jnlp.version" value="all-otrunk-snapshot-0.1.0-20130115.211313"/>
            <launchProperties key="sds_time" value="1358359530250"/>
            <launchProperties key="sailotrunk.otmlurl" value="http://portal.local/investigations/1007.dynamic_otml?learner_id=9308"/>
          </sessionBundles>'
      }
      @valid_attributes_with_multiple_select_and_rationale_updated = {
        :bundle_logger_id => 1,
        :position => 5,
        :body => '<sessionBundles xmlns:xmi="http://www.omg.org/XMI" xmlns:sailuserdata="sailuserdata" start="2013-01-18T09:49:10.607-0800" stop="2013-01-18T09:49:32.429-0800" curnitUUID="cccccccc-0009-0000-0000-000000000000" sessionUUID="2b0acc00-ce55-455d-9814-5a887eb4588b" lastModified="2013-01-18T09:49:32.492-0800" timeDifference="-3493" localIP="192.168.56.1">
          <sockParts podId="dddddddd-0002-0000-0000-000000000000" rimName="ot.learner.data" rimShape="[B">
            <sockEntries value="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" millisecondsOffset="21883"/>
          </sockParts>
          <agents role="RUN_WORKGROUP"/>
          <sdsReturnAddresses>http://portal.local/dataservice/bundle_loggers/9549/bundle_contents.bundle</sdsReturnAddresses>
          <launchProperties key="previous.bundle.session.id" value="458d4298-f8e3-4eb8-bd81-848c98bc8fdc"/>
          <launchProperties key="maven.jnlp.version" value="all-otrunk-snapshot-0.1.0-20130117.211006"/>
          <launchProperties key="sds_time" value="1358531350607"/>
          <launchProperties key="sailotrunk.otmlurl" value="http://portal.local/investigations/1007.dynamic_otml?learner_id=9308"/>
        </sessionBundles>'
      }

    end

    before(:each) do
      reset_table_index(Embeddable::MultipleChoice, 3896)
      reset_table_index(Embeddable::MultipleChoiceChoice, 18145)
      reset_table_index(Embeddable::ImageQuestion, 846)
      reset_table_index(Dataservice::Blob, 11892)
      restart_transaction
    end

    it "should correctly extract multi-line snapshot notes" do
      blogger = Dataservice::BundleLogger.create!()
      student = Portal::Student.create!()
      offering = Portal::Offering.create!()
      offering.runnable = Investigation.create!(:name => "Test Investigation")
      offering.save
      learner = Portal::Learner.create!(:bundle_logger_id => blogger.id, :student_id => student.id, :offering_id => offering.id)
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

    it "should correctly extract multiple selection mc questions with rationales" do
      blogger = Dataservice::BundleLogger.create!()
      student = Portal::Student.create!()
      offering = Portal::Offering.create!()
      offering.runnable = Investigation.create!(:name => "Test Investigation")
      offering.save
      learner = Portal::Learner.create!(:bundle_logger_id => blogger.id, :student_id => student.id, :offering_id => offering.id)
      learner.bundle_logger = blogger
      learner.save!
      blogger.reload
      learner.reload
      blogger.learner.should_not be_nil
      learner.bundle_logger.should_not be_nil
      @valid_attributes_with_multiple_select_and_rationale[:bundle_logger_id] = blogger.id

      # create multiple_choices with ids = 18145
      # create image_question with id = 847

      emb = nil
      begin
        emb = Embeddable::ImageQuestion.create!(:user_id => 1, :name => 'image question 847', :prompt => "Please choose an image")
      end until emb.id >= 847

      emb = nil
      begin
        emb = Embeddable::MultipleChoice.create!(:user_id => 1, :name => 'mc', :prompt => "mc prompt?", :description => 'mc')
      end until emb.id >= 3903

      i = 1
      begin
        emb = Embeddable::MultipleChoiceChoice.create!(:choice => "someChoice #{i}")
        i += 1
      end until emb.id >= 18170

      [{:mc => 3897, :choices => [18145]},
       {:mc => 3901, :choices => [18157,18158]},
       {:mc => 3902, :choices => [18162]},
       {:mc => 3903, :choices => [18165,18170]} ].each do |cfg|
        choice = Embeddable::MultipleChoice.find(cfg[:mc])
        cfg[:choices].each do |cid|
          choice_choice = Embeddable::MultipleChoiceChoice.find(cid)
          choice_choice.multiple_choice = choice
          choice_choice.save!
        end
      end

      bundle_content = Dataservice::BundleContent.create!(@valid_attributes_with_multiple_select_and_rationale)

      # create blob with id = 11892
      emb = nil
      begin
        emb = Dataservice::Blob.create!(:content => 'image', :bundle_content_id => bundle_content.id)
      end until emb.id >= 11892

      bundle_content.bundle_logger = blogger
      bundle_content.save!
      bundle_content.reload
      blogger.reload
      bundle_content.bundle_logger_id.should eql(learner.bundle_logger.id)
      bundle_content.bundle_logger.learner.id.should eql(learner.id)


      learner.multiple_choices.size.should eql(4)
      learner.multiple_choices.each do |saveable|
        case saveable.multiple_choice_id
        when 3897
          saveable.answer.should eql([{:answer => "someChoice 1", :correct => nil}])
        when 3901
          # saveable.answer.should eql("someChoice 13, someChoice 14")
          saveable.answer.should eql([{:answer => "someChoice 13", :correct => nil},{:answer => "someChoice 14", :correct => nil}])
        when 3902
          saveable.answer.should eql([{:answer => "someChoice 18", :rationale => "Soft feels really nice", :correct => nil}])
        when 3903
          # saveable.answer.should eql("someChoice 21, someChoice 26")
          saveable.answer.should eql([{:answer => "someChoice 21", :rationale => "It's cold", :correct => nil},{:answer => "someChoice 26", :rationale => "Are yellow", :correct => nil}])
        else
          raise "Unexpected multiple choice saveable!"
        end
      end
    end

    it "should correctly update multiple selection mc questions with rationales" do
      blogger = Dataservice::BundleLogger.create!()
      student = Portal::Student.create!()
      offering = Portal::Offering.create!()
      offering.runnable = Investigation.create!(:name => "Test Investigation")
      offering.save
      learner = Portal::Learner.create!(:bundle_logger_id => blogger.id, :student_id => student.id, :offering_id => offering.id)
      learner.bundle_logger = blogger
      learner.save!
      blogger.reload
      learner.reload
      blogger.learner.should_not be_nil
      learner.bundle_logger.should_not be_nil
      @valid_attributes_with_multiple_select_and_rationale[:bundle_logger_id] = blogger.id
      @valid_attributes_with_multiple_select_and_rationale_updated[:bundle_logger_id] = blogger.id

      # create multiple_choices with ids = 18145
      # create image_question with id = 847

      emb = nil
      begin
        emb = Embeddable::ImageQuestion.create!(:user_id => 1, :name => 'image question 847', :prompt => "Please choose an image")
      end until emb.id >= 847

      emb = nil
      begin
        emb = Embeddable::MultipleChoice.create!(:user_id => 1, :name => 'mc', :prompt => "mc prompt?", :description => 'mc')
      end until emb.id >= 3903

      i = 1
      begin
        emb = Embeddable::MultipleChoiceChoice.create!(:choice => "someChoice #{i}")
        i += 1
      end until emb.id >= 18170

      [{:mc => 3897, :choices => [18145]},
       {:mc => 3901, :choices => [18157,18158]},
       {:mc => 3902, :choices => [18162]},
       {:mc => 3903, :choices => [18165,18170]} ].each do |cfg|
        choice = Embeddable::MultipleChoice.find(cfg[:mc])
        cfg[:choices].each do |cid|
          choice_choice = Embeddable::MultipleChoiceChoice.find(cid)
          choice_choice.multiple_choice = choice
          choice_choice.save!
        end
      end

      bundle_content = Dataservice::BundleContent.create!(@valid_attributes_with_multiple_select_and_rationale)

      # create blob with id = 11892
      emb = nil
      begin
        emb = Dataservice::Blob.create!(:content => 'image', :bundle_content_id => bundle_content.id)
      end until emb.id >= 11892

      bundle_content.bundle_logger = blogger
      bundle_content.save!
      bundle_content.reload
      blogger.reload
      bundle_content.bundle_logger_id.should eql(learner.bundle_logger.id)
      bundle_content.bundle_logger.learner.id.should eql(learner.id)


      bundle_content = Dataservice::BundleContent.create!(@valid_attributes_with_multiple_select_and_rationale_updated)

      bundle_content.bundle_logger = blogger
      bundle_content.save!
      bundle_content.reload
      blogger.reload
      bundle_content.bundle_logger_id.should eql(learner.bundle_logger.id)
      bundle_content.bundle_logger.learner.id.should eql(learner.id)


      learner.multiple_choices.size.should eql(4)
      learner.multiple_choices.each do |saveable|
        case saveable.multiple_choice_id
        when 3897
          saveable.answer.should eql([{:answer => "someChoice 1", :correct => nil}])
        when 3901
          # saveable.answer.should eql("someChoice 13, someChoice 14")
          saveable.answer.should eql([{:answer => "someChoice 13", :correct => nil},{:answer => "someChoice 14", :correct => nil}])
        when 3902
          saveable.answer.should eql([{:answer => "someChoice 18", :rationale => "Soft feels really nice, indeed.", :correct => nil}])
        when 3903
          # saveable.answer.should eql("someChoice 21, someChoice 26")
          saveable.answer.should eql([{:answer => "someChoice 21", :rationale => "It's cold", :correct => nil},{:answer => "someChoice 22", :rationale => "this is a really long answer that wikll keep going and going until the end of the page and keep scrolling", :correct => nil},{:answer => "someChoice 26", :rationale => "Are yellow", :correct => nil}])
        else
          raise "Unexpected multiple choice saveable!"
        end
      end
    end

  end
end
