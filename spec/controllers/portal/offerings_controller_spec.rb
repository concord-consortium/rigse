require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::OfferingsController do
  describe "Show Jnlp Offering" do
    it "renders a jnlp for an admin" do
      offering = FactoryBot.create(:portal_offering)
      admin = FactoryBot.generate :admin_user
      sign_in admin
      get :show, :id => offering.id, :format => :jnlp
      expect(response).to render_template('shared/_installer')
    end

    it "renders a jnlp for a teacher" do
      teacher = FactoryBot.create(:portal_teacher)
      offering = FactoryBot.create(:portal_offering, :clazz => teacher.clazzes.first)
      sign_in teacher.user
      get :show, :id => offering.id, :format => :jnlp
      expect(response).to render_template('shared/_installer')
    end

    it "renders a jnlp as a learner" do
      learner = FactoryBot.create(:full_portal_learner)
      sign_in learner.student.user
      get :show, :id => learner.offering.id, :format => :jnlp
      expect(response).to render_template('shared/_installer')
    end
  end

  describe "External Activities Offering" do
    before(:each) do
      generate_default_settings_with_mocks
      generate_portal_resources_with_mocks
      allow(Admin::Settings).to receive(:default_settings).and_return(@mock_settings)

      # this seems like it would all be better with some factories for clazz, runnable, offering, and learner
      @clazz = mock_model(Portal::Clazz, :is_student? => true, :is_teacher? => false)
      @runnable_opts = {
        :name      => "Some Activity",
        :url       => "http://example.com",
        :save_path => "/path/to/save",
      }
      @runnable = FactoryBot.create(:external_activity, @runnable_opts )
      @offering = mock_model(Portal::Offering, :runnable => @runnable, :clazz => @clazz)
      @user = FactoryBot.create(:confirmed_user, :email => "test@test.com", :password => "password", :password_confirmation => "password")
      @portal_student = mock_model(Portal::Student)
      @learner = mock_model(Portal::Learner, :id => 34, :offering => @offering, :student => @portal_student)
      allow(controller).to receive(:setup_portal_student).and_return(@learner)
      allow(Portal::Offering).to receive(:find).and_return(@offering)
      sign_in @user
    end

    it "saves learner data in the cookie" do
      @runnable.append_learner_id_to_url = false

      get :show, :id => @offering.id, :format => 'run_resource_html'
      expect(response.cookies["save_path"]).to eq(@offering.runnable.save_path)
      expect(response.cookies["learner_id"]).to eq(@learner.id.to_s)
      expect(response.cookies["student_name"]).to eq("#{@user.first_name} #{@user.last_name}")
      expect(response.cookies["activity_name"]).to eq(@offering.runnable.name)
      expect(response.cookies["class_id"]).to eq(@clazz.id.to_s)

      expect(response).to redirect_to(@runnable_opts[:url])
    end

    it "appends the learner id to the url" do
      @runnable.append_learner_id_to_url = true
      # @runnable.stub!(:append_learner_id_to_url).and_return(true)
      get :show, :id => @offering.id, :format => 'run_resource_html'
      expect(response).to redirect_to(@runnable_opts[:url] + "?learner=#{@learner.id}")
    end
  end

  describe "POST offering_collapsed_status" do
    before(:each) do
      @mock_school = FactoryBot.create(:portal_school)

      @admin_user = FactoryBot.generate(:admin_user)
      @manager_user = FactoryBot.generate(:manager_user)
      @researcher_user = FactoryBot.generate(:researcher_user)
      @author_user = FactoryBot.generate(:author_user)
      @guest_user = FactoryBot.generate(:anonymous_user)
      @student_user = FactoryBot.create(:confirmed_user, :login => "authorized_student")
      @portal_student = FactoryBot.create(:portal_student, :user => @student_user)
      @authorized_teacher = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:confirmed_user, :login => "authorized_teacher"), :schools => [@mock_school])
      @authorized_teacher_user = @authorized_teacher.user
      @offering = mock_model(Portal::Offering, :runnable => @runnable, :clazz => @clazz)
      @params = {
        :id => @offering.id
      }
    end
    it "should render nothing and return for users other than teacher" do
      login_admin
      xhr :post, :offering_collapsed_status, @params
      expect(response.body).to be_blank

      sign_in @manager_user
      xhr :post, :offering_collapsed_status, @params
      expect(response.body).to be_blank

      sign_in @researcher_user
      xhr :post, :offering_collapsed_status, @params
      expect(response.body).to be_blank

      sign_in @author_user
      xhr :post, :offering_collapsed_status, @params
      expect(response.body).to be_blank

      sign_in @guest_user
      xhr :post, :offering_collapsed_status, @params
      expect(response.body).to be_blank

      sign_in @student_user
      xhr :post, :offering_collapsed_status, @params
      expect(response.body).to be_blank
    end
    it "should maintain the offering collapse expand status when user is a teacher" do
      sign_in @authorized_teacher_user
      #when teacher has never expanded or collapsed before
      portal_teacher_full_status = Portal::TeacherFullStatus.find_by_offering_id_and_teacher_id(@params[:id], @authorized_teacher.id)
      expect(portal_teacher_full_status).to be_nil

      # after first expand
      xhr :post, :offering_collapsed_status, @params
      portal_teacher_full_status = Portal::TeacherFullStatus.find_by_offering_id_and_teacher_id(@params[:id], @authorized_teacher.id)
      expect(portal_teacher_full_status).not_to be_nil
      expect(portal_teacher_full_status.offering_collapsed).to eq(false)
      expect(response.body).to be_blank

      #when teacher has collapsed and expanded many times before
      xhr :post, :offering_collapsed_status, @params
      portal_teacher_full_status.reload
      expect(portal_teacher_full_status).not_to be_nil
      expect(portal_teacher_full_status.offering_collapsed).to eq(true)
      expect(response.body).to be_blank
    end
  end

  describe "GET report" do
    let(:physics_investigation) { FactoryBot.create(
        :investigation,
        :name => 'physics_inv',
        :publication_status => 'published') }

    let(:offering) { FactoryBot.create(
        :portal_offering,
        runnable_id: physics_investigation,
        runnable_type: 'Activity',
        clazz: clazz)}

    let(:clazz)       { FactoryBot.create :portal_clazz, teachers: [teacher] }
    let(:post_params) { {id: offering.id }      }
    let(:eacher_user) { FactoryBot.generate()          }
    let(:teacher)     { FactoryBot.create :teacher }
    let(:teacher_b)   { FactoryBot.create :teacher }

    before(:each) do
      sign_in user
    end

    describe "When the teacher of the class requests the report" do
      let(:user)           { teacher.user }
      let(:report_url)     { "https://concord-consortium.github.io/portal-report/" }
      let(:report_domains) { "concord-consortium.github.io" }
      before(:each) do
        allow(ENV).to receive(:[]).and_return('')
        allow(ENV).to receive(:[]).with("REPORT_VIEW_URL").and_return(report_url)
        allow(ENV).to receive(:[]).with("REPORT_DOMAINS").and_return(report_domains)
      end

      it "should redirect to the external reporting service as configured by the environment" do
        get :report, post_params
        expect(response.location).to match(/#{report_url}/)
      end
      it "should include an authentication token parameter" do
        get :report, post_params
        expect(response.location).to match(/token=([0-9]|[a-f]){32}/)
      end
    end

    describe "when the current user is a teacher without access to this offering" do
      let(:user) { teacher_b.user }
      it "should redirect the user to /recent_activity" do
        get :report, post_params
        expect(response).to redirect_to :recent_activity
      end
    end
  end


  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, {}, {}

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, id: FactoryBot.create(:portal_offering).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#activate' do
    let(:referrer)  { "https://foo.bar.com/some/path.html" }

    xit 'GET activate' do
      allow(request).to receive(:env).and_return({'HTTP_REFERER' => referrer})

      admin = FactoryBot.generate :admin_user
      sign_in admin
      get :activate, id: FactoryBot.create(:portal_offering).to_param

      expect(response).to have_http_status(:redirect)
    end
  end                           

  # TODO: auto-generated
  describe '#deactivate' do
    let(:referrer)  { "https://foo.bar.com/some/path.html" }

    xit 'GET deactivate' do
      allow(request).to receive(:env).and_return({'HTTP_REFERER' => referrer})
      admin = FactoryBot.generate :admin_user
      sign_in admin
      get :deactivate, id: FactoryBot.create(:portal_offering).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#answers' do
    it 'GET answers' do
      admin = FactoryBot.generate :admin_user
      sign_in admin
      get :answers, id: FactoryBot.create(:portal_offering).to_param, questions: []

      expect(response).to have_http_status(:redirect)
    end
  end


  # TODO: auto-generated
  describe '#student_report' do
    it 'GET student_report' do
      get :student_report, id: FactoryBot.create(:portal_offering).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#external_report' do
    it 'GET external_report' do
      get :external_report, id: FactoryBot.create(:portal_offering).to_param

      expect(response).to have_http_status(:redirect)
    end
  end
end
