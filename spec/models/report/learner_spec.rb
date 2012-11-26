require File.expand_path('../../../spec_helper', __FILE__)

describe Report::Learner do
  before(:each) do
    @user     = mock_model(User, 
      :name => "joe"
    )
    
    @student  = mock_model(Portal::Student, 
      :user => @user
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

    @learner  = mock_model(Portal::Learner, 
      :student  => @student,
      :offering => @offering,
      :bundle_logger => @bundle_logger,
      :periodic_bundle_logger => @periodic_bundle_logger,
    )
  end

  it "should create a valid instance with adequate mocks" do
    @report = Report::Learner.create(:learner => @learner)
  end

  describe "with no bundle_loggers" do
    before(:each) do
      @learner.stub!(:periodic_bundle_logger => nil)
      @bunlde_logger.stub!(:last_non_empty_bundle_content => nil)
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




end
