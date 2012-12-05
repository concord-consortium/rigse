require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::OfferingsController do
  describe "Show Jnlp Offering" do
    it "renders a jnlp" do
      offering = Factory(:portal_offering)
      get :show, :id => offering.id, :format => :jnlp
      response.should render_template('shared/_show_or_installer')
    end

    it "renders a jnlp as a learner" do
      learner = Factory(:full_portal_learner)
      stub_current_user(learner.student.user)
      get :show, :id => learner.offering.id, :format => :jnlp
      response.should render_template('shared/_learn_or_installer')
    end
  end

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
      @report_learner = mock_model(Report::Learner,
        :last_run=     => nil,
        :update_fields => nil)
      @learner = mock_model(Portal::Learner, 
        :id => 34, 
        :offering => @offering, 
        :student  => @portal_student, 
        :report_learner => @report_learner)
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

    it 'should display previous answers when view again' do
      @clazz.should_receive(:is_student?).and_return(true)

      mc_sym = "embeddable__multiple_choice_#{@multiple_choice.id}"
      or_sym = "embeddable__open_response_#{@open_response.id}"

      choice = @multiple_choice.choices.last
      answers = {mc_sym => "embeddable__multiple_choice_choice_#{choice.id}", or_sym => "This is an OR answer"}

      post :answers, :id => @offering.id, :questions => answers

      get :show, :id => @offering.id, :format => 'run_html'

      or_regex = /<textarea.*?name='questions\[embeddable__open_response_(\d+)\].*?>[^<]*This is an OR answer[^<]*<\/textarea>/m
      response.body.should =~ or_regex

      mc_regex = /<input.*?checked.*?name='questions\[embeddable__multiple_choice_(\d+)\]'.*?type='radio'.*?value='embeddable__multiple_choice_choice_#{choice.id}'/
      response.body.should =~ mc_regex
    end

    it 'should disable the submit button when there is no learner' do
      controller.stub!(:setup_portal_student).and_return(nil)
      get :show, :id => @offering.id, :format => 'run_html'
      response.body.should =~ /<input.*class='disabled'.*type='submit'/
    end
  end
  
  describe "POST offering_collapsed_status" do
    before(:each) do
      @mock_semester = Factory.create(:portal_semester, :name => "Fall")
      @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])
      
      @admin_user = Factory.next(:admin_user)
      @manager_user = Factory.next(:manager_user)
      @researcher_user = Factory.next(:researcher_user)
      @author_user = Factory.next(:author_user)
      @guest_user = Factory.next(:anonymous_user)
      @student_user = Factory.create(:user, :login => "authorized_student")
      @portal_student = Factory.create(:portal_student, :user => @student_user)
      @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "authorized_teacher"), :schools => [@mock_school])
      @authorized_teacher_user = @authorized_teacher.user
      @offering = mock_model(Portal::Offering, :runnable => @runnable, :clazz => @clazz)
      @params = {
        :id => @offering.id
      }
    end
    it "should render nothing and return for users other than teacher" do
      stub_current_user :admin_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      stub_current_user :manager_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank
      
      stub_current_user :researcher_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      stub_current_user :author_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      stub_current_user :guest_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      stub_current_user :student_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank
    end
    it "should maintain the offering collapse expand status when user is a teacher" do
      stub_current_user :authorized_teacher_user
      #when teacher has never expanded or collapsed before
      portal_teacher_full_status = Portal::TeacherFullStatus.find_by_offering_id_and_teacher_id(@params[:id], @authorized_teacher.id)
      assert_nil(portal_teacher_full_status)
      
      # after first expand
      xhr :post, :offering_collapsed_status, @params
      portal_teacher_full_status = Portal::TeacherFullStatus.find_by_offering_id_and_teacher_id(@params[:id], @authorized_teacher.id)
      assert_not_nil(portal_teacher_full_status)
      assert_equal(portal_teacher_full_status.offering_collapsed, false)
      response.body.should be_blank
      
      #when teacher has collapsed and expanded many times before
      xhr :post, :offering_collapsed_status, @params
      portal_teacher_full_status.reload
      assert_not_nil(portal_teacher_full_status)
      assert_equal(portal_teacher_full_status.offering_collapsed, true)
      response.body.should be_blank
    end
  end
  
  describe "GET report" do 
    before(:each) do
      @mock_semester = Factory.create(:portal_semester, :name => "Fall")
      @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])
      @teacher_user = Factory.create(:user, :login => "teacher")
      @teacher = Factory.create(:portal_teacher, :user => @teacher_user, :schools => [@mock_school])
      @author_user = Factory.next(:author_user)
      @student_user = Factory.create(:user)
      @student = Factory.create(:portal_student,:user_id=> @student_user.id)
      @physics_investigation = Factory.create(:investigation, :name => 'physics_inv', :user => @author_user, :publication_status => 'published')
      @laws_of_motion_activity = Factory.create(:activity, :name => 'laws_of_motion_activity' ,:investigation_id => @physics_investigation.id, :user => @author_user)
      @physics_clazz = Factory.create(:portal_clazz, :name => 'Physics Clazz', :course => @mock_course,:teachers => [@teacher])
      @offering=Factory.create(:portal_offering,:status=>'active',:runnable_id=>@laws_of_motion_activity.id,:runnable_type=>'Activity',:clazz=>@physics_clazz)
      @portal_learner=Factory.create(:portal_learner,:offering_id=>@offering.id, :student_id => @student.id)
      @portal_student_clazz=Factory.create(:portal_student_clazz,:student_id=>@student.id,:clazz_id=>@physics_clazz.id)
      @section=Factory.create(:section,:user_id=>@teacher_user.id,:activity_id=>@laws_of_motion_activity.id)
      @page=Factory.create(:page,:user_id=>@teacher_user.id,:section_id=>@section.id)
      @embeddable=Factory.create(:embeddable_xhtml,:user_id=>@teacher_user.id)
      @page.add_embeddable(@embeddable)
      stub_current_user :teacher_user
    end
    
    it "should show report when no filter is set" do
      @post_params = {
        :id => @offering.id,
      }
      get :report, @post_params
      assert_equal assigns[:offering], @offering
      assert_equal assigns[:report_embeddable_filter], []
      response.should render_template 'layouts/report'
    end
    
    it "should show report when filter is set" do
      #creating report embeddable filter
      report_embeddable=Factory.create(:open_response,:user_id=>@teacher_user.id)
      @offering.report_embeddable_filter.embeddables = [report_embeddable]
      @offering.report_embeddable_filter.save!
      @post_params = {
        :id => @offering.id
      }
      get :report, @post_params
      assert_equal assigns[:offering], @offering
      assert_equal assigns[:report_embeddable_filter], @offering.report_embeddable_filter.embeddables
      response.should render_template 'layouts/report'
    end
    
    it "should show report for an activity when filter is set and ignore is set to false for report embeddable filter" do
      #creating report embeddable filter
      report_embeddable=Factory.create(:open_response,:user_id=>@teacher_user.id)
      @offering.report_embeddable_filter.embeddables = [report_embeddable]
      @offering.report_embeddable_filter.ignore = false
      @offering.report_embeddable_filter.save!
      @post_params = {
        :id => @offering.id,
        :activity_id => @laws_of_motion_activity.id
      }
      get :report, @post_params
      assert_equal assigns[:offering], @offering
      assert_equal assigns[:report_embeddable_filter], @offering.report_embeddable_filter.embeddables
      assert_equal assigns[:activity_report_id], @post_params[:activity_id].to_i
      @portal_learner.reload
      @offering.reload
      assert_equal assigns[:offering].report_embeddable_filter.embeddables, [@embeddable]
      assert_equal assigns[:offering].report_embeddable_filter.ignore, false
      response.should render_template 'layouts/report'
    end
    
    it "should show report for an activity when filter is set and ignore is set to true for report embeddable filter" do
      #creating report embeddable filter
      report_embeddable=Factory.create(:open_response,:user_id=>@teacher_user.id)
      @offering.report_embeddable_filter.embeddables = [report_embeddable]
      @offering.report_embeddable_filter.ignore = true
      @offering.report_embeddable_filter.save!
      @post_params = {
        :id => @offering.id,
        :activity_id => @laws_of_motion_activity.id
      }
      get :report, @post_params
      assert_equal assigns[:offering], @offering
      assert_equal assigns[:report_embeddable_filter], @offering.report_embeddable_filter.embeddables
      assert_equal assigns[:activity_report_id], @post_params[:activity_id].to_i
      @portal_learner.reload
      @offering.reload
      assert_equal assigns[:offering].report_embeddable_filter.embeddables, [@embeddable]
      assert_equal assigns[:offering].report_embeddable_filter.ignore, false
      response.should render_template 'layouts/report'
    end
  end
end
