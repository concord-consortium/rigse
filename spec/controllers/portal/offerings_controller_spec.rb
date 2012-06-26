require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::OfferingsController do
  describe "External Activities Offering" do
    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
      Admin::Project.stub!(:default_project).and_return(@mock_project)

      # this seems like it would all be better with some factories for clazz, runnable, offering, and learner
      @clazz = mock_model(Portal::Clazz)
      @runnable_opts = {
        :name      => "Some Activity",
        :url       => "http://example.com",
        :save_path => "/path/to/save",
      }
      @runnable = Factory(:external_activity, @runnable_opts )
      @offering = mock_model(Portal::Offering, :runnable => @runnable, :clazz => @clazz)
      @user = Factory(:user, :email => "test@test.com", :password => "password", :password_confirmation => "password")
      @portal_student = mock_model(Portal::Student)
      @learner = mock_model(Portal::Learner, :id => 34, :offering => @offering, :student => @portal_student)
      controller.stub!(:setup_portal_student).and_return(@learner)
      Portal::Offering.stub!(:find).and_return(@offering)
      stub_current_user :user
    end

    it "saves learner data in the cookie" do
      @runnable.append_learner_id_to_url = false

      get :show, :id => @offering.id, :format => 'run_external_html'
      response.cookies["save_path"].should == @offering.runnable.save_path
      response.cookies["learner_id"].should == @learner.id.to_s
      response.cookies["student_name"].should == "#{current_user.first_name} #{current_user.last_name}"
      response.cookies["activity_name"].should == @offering.runnable.name
      response.cookies["class_id"].should == @clazz.id.to_s

      response.should redirect_to(@runnable_opts[:url])
    end

    it "appends the learner id to the url" do
      @runnable.append_learner_id_to_url = true
      # @runnable.stub!(:append_learner_id_to_url).and_return(true)
      get :show, :id => @offering.id, :format => 'run_external_html'
      response.should redirect_to(@runnable_opts[:url] + "?learner=#{@learner.id}")
    end
  end

  describe "run_html offering" do
    render_views
    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
      Admin::Project.stub!(:default_project).and_return(@mock_project)

      # this seems like it would all be better with some factories for clazz, runnable, offering, and learner
      @clazz = mock_model(Portal::Clazz)
      
      @runnable = Factory(:page)
      @xhtml = Factory(:xhtml)
      @multiple_choice = Factory(:multiple_choice)
      @open_response = Factory(:open_response)

      @xhtml.pages << @runnable
      @multiple_choice.pages << @runnable
      @open_response.pages << @runnable

      @xhtml.save
      @xhtml.reload

      @multiple_choice.save
      @multiple_choice.create_default_choices
      @multiple_choice.reload

      @open_response.save
      @open_response.reload

      @offering = mock_model(Portal::Offering, :id => 45, :runnable => @runnable, :clazz => @clazz)
      @user = Factory(:user, :email => "test@test.com", :password => "password", :password_confirmation => "password")
      @portal_student = mock_model(Portal::Student)
      @learner = mock_model(Portal::Learner, :id => 34, :offering => @offering, :student => @portal_student)
      controller.stub!(:setup_portal_student).and_return(@learner)
      Portal::Offering.stub!(:find).and_return(@offering)
      stub_current_user :user
    end

    it 'should render an html form' do
      get :show, :id => @offering.id, :format => 'run_html'

      form_regex = /<form.*?action='\/portal\/offerings\/(\d+)\/answers'/
      response.body.should =~ form_regex
      response.body =~ form_regex
      $1.to_i.should == @offering.id

      or_regex = /<textarea.*?name='questions\[embeddable__open_response_(\d+)\]'/
      response.body.should =~ or_regex
      response.body =~ or_regex
      $1.to_i.should == @open_response.id

      mc_regex = /<input.*?name='questions\[embeddable__multiple_choice_(\d+)\]'.*?type='radio'.*?value='embeddable__multiple_choice_choice_\d+'/
      response.body.should =~ mc_regex
      response.body =~ mc_regex
      $1.to_i.should == @multiple_choice.id

      xhtml_regex = /<div.*?id='details_embeddable__xhtml_(\d+)'/
      response.body.should =~ xhtml_regex
      response.body =~ xhtml_regex
      $1.to_i.should == @xhtml.id
    end

    it 'should create saveables when the form is submitted' do
      @clazz.should_receive(:is_student?).and_return(true)

      mc_sym = "embeddable__multiple_choice_#{@multiple_choice.id}"
      or_sym = "embeddable__open_response_#{@open_response.id}"

      choice = @multiple_choice.choices.last
      answers = {mc_sym => "embeddable__multiple_choice_choice_#{choice.id}", or_sym => "This is an OR answer"}

      or_saveables_size = Saveable::OpenResponse.find(:all).size
      mc_saveables_size = Saveable::MultipleChoice.find(:all).size

      post :answers, :id => @offering.id, :questions => answers

      or_saveables = Saveable::OpenResponse.find(:all)
      or_saveables.size.should == (or_saveables_size + 1)
      or_saveables.last.answer.should == "This is an OR answer"

      mc_saveables = Saveable::MultipleChoice.find(:all)
      mc_saveables.size.should == (mc_saveables_size + 1)
      mc_saveables.last.answer.should == choice.choice
    end

    it 'should disable the submit button when there is no learner' do
      controller.stub!(:setup_portal_student).and_return(nil)
      get :show, :id => @offering.id, :format => 'run_html'
      response.body.should =~ /<input.*class='disabled'.*type='submit'/
    end
  end
end
