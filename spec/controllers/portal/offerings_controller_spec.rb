require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::OfferingsController do
  describe "Show Jnlp Offering" do
    it "renders a jnlp for an admin" do
      offering = Factory(:portal_offering)
      admin = Factory.next :admin_user
      sign_in admin
      get :show, :id => offering.id, :format => :jnlp
      response.should render_template('shared/_installer')
    end

    it "renders a jnlp for a teacher" do
      teacher = Factory(:portal_teacher)
      offering = Factory(:portal_offering, :clazz => teacher.clazzes.first)
      sign_in teacher.user
      get :show, :id => offering.id, :format => :jnlp
      response.should render_template('shared/_installer')
    end

    it "renders a jnlp as a learner" do
      learner = Factory(:full_portal_learner)
      sign_in learner.student.user
      get :show, :id => learner.offering.id, :format => :jnlp
      response.should render_template('shared/_installer')
    end
  end

  describe "External Activities Offering" do
    before(:each) do
      generate_default_settings_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
      Admin::Settings.stub!(:default_settings).and_return(@mock_settings)

      # this seems like it would all be better with some factories for clazz, runnable, offering, and learner
      @clazz = mock_model(Portal::Clazz, :is_student? => true, :is_teacher? => false)
      @runnable_opts = {
        :name      => "Some Activity",
        :url       => "http://example.com",
        :save_path => "/path/to/save",
      }
      @runnable = Factory(:external_activity, @runnable_opts )
      @offering = mock_model(Portal::Offering, :runnable => @runnable, :clazz => @clazz)
      @user = Factory(:confirmed_user, :email => "test@test.com", :password => "password", :password_confirmation => "password")
      @portal_student = mock_model(Portal::Student)
      @learner = mock_model(Portal::Learner, :id => 34, :offering => @offering, :student => @portal_student)
      controller.stub!(:setup_portal_student).and_return(@learner)
      Portal::Offering.stub!(:find).and_return(@offering)
      sign_in @user
    end

    it "saves learner data in the cookie" do
      @runnable.append_learner_id_to_url = false

      get :show, :id => @offering.id, :format => 'run_resource_html'
      response.cookies["save_path"].should == @offering.runnable.save_path
      response.cookies["learner_id"].should == @learner.id.to_s
      response.cookies["student_name"].should == "#{@user.first_name} #{@user.last_name}"
      response.cookies["activity_name"].should == @offering.runnable.name
      response.cookies["class_id"].should == @clazz.id.to_s

      response.should redirect_to(@runnable_opts[:url])
    end

    it "appends the learner id to the url" do
      @runnable.append_learner_id_to_url = true
      # @runnable.stub!(:append_learner_id_to_url).and_return(true)
      get :show, :id => @offering.id, :format => 'run_resource_html'
      response.should redirect_to(@runnable_opts[:url] + "?learner=#{@learner.id}")
    end
  end

  describe "POST offering_collapsed_status" do
    before(:each) do
      @mock_school = Factory.create(:portal_school)

      @admin_user = Factory.next(:admin_user)
      @manager_user = Factory.next(:manager_user)
      @researcher_user = Factory.next(:researcher_user)
      @author_user = Factory.next(:author_user)
      @guest_user = Factory.next(:anonymous_user)
      @student_user = Factory.create(:confirmed_user, :login => "authorized_student")
      @portal_student = Factory.create(:portal_student, :user => @student_user)
      @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:confirmed_user, :login => "authorized_teacher"), :schools => [@mock_school])
      @authorized_teacher_user = @authorized_teacher.user
      @offering = mock_model(Portal::Offering, :runnable => @runnable, :clazz => @clazz)
      @params = {
        :id => @offering.id
      }
    end
    it "should render nothing and return for users other than teacher" do
      login_admin
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      sign_in @manager_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      sign_in @researcher_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      sign_in @author_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      sign_in @guest_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank

      sign_in @student_user
      xhr :post, :offering_collapsed_status, @params
      response.body.should be_blank
    end
    it "should maintain the offering collapse expand status when user is a teacher" do
      sign_in @authorized_teacher_user
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
    let(:physics_investigation) { Factory.create(
        :investigation,
        :name => 'physics_inv',
        :publication_status => 'published') }

    let(:offering) { Factory.create(
        :portal_offering,
        runnable_id: physics_investigation,
        runnable_type: 'Activity',
        clazz: clazz)}

    let(:clazz)       { Factory.create :portal_clazz, teachers: [teacher] }
    let(:post_params) { {id: offering.id }      }
    let(:eacher_user) { Factory.next()          }
    let(:teacher)     { Factory.create :teacher }
    let(:teacher_b)   { Factory.create :teacher }

    before(:each) do
      sign_in user
    end

    describe "When the teacher of the class requests the report" do
      let(:user)           { teacher.user }
      let(:report_url)     { "https://concord-consortium.github.io/portal-report/" }
      let(:report_domains) { "concord-consortium.github.io" }
      before(:each) do
        ENV.stub(:[]).and_return('')
        ENV.stub(:[]).with("REPORT_VIEW_URL").and_return(report_url)
        ENV.stub(:[]).with("REPORT_DOMAINS").and_return(report_domains)
      end

      it "should redirect to the external reporting service as configured by the environment" do
        get :report, post_params
        response.location.should =~ /#{report_url}/
      end
      it "should include an authentication token parameter" do
        get :report, post_params
        response.location.should =~ /token=([0-9]|[a-f]){32}/
      end
    end

    describe "when the current user is a teacher without access to this offering" do
      let(:user) { teacher_b.user }
      it "should redirect the user to /recent_activity" do
        get :report, post_params
        response.should redirect_to :recent_activity
      end
    end
  end
end
