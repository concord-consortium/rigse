require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::OfferingsController do
  describe "External Activities Offering" do
    before(:each) do
      generate_default_settings_with_mocks
      generate_portal_resources_with_mocks
      allow(Admin::Settings).to receive(:default_settings).and_return(@mock_settings)

      # this seems like it would all be better with some factories for clazz, runnable, offering, and learner
      @clazz = mock_model(Portal::Clazz, :is_student? => true, :is_teacher? => false, :class_info_url => "http://test.host", :class_hash => "abc123")
      @runnable_opts = {
        :name      => "Some Activity",
        :url       => "http://example.com",
        :save_path => "/path/to/save"
      }
      @runnable = FactoryBot.create(:external_activity, @runnable_opts )
      @offering = mock_model(Portal::Offering, :runnable => @runnable, :clazz => @clazz, :domain => 'http://test.host/', :logging => false, :resource_link_id => 1)
      @user = FactoryBot.create(:confirmed_user, :email => "test@test.com", :password => "password", :password_confirmation => "password")
      @portal_student = mock_model(Portal::Student, :user_id => @user.id, :domain_id => 1, :platform_id => 1)
      @learner = mock_model(Portal::Learner, :id => 34, :offering => @offering, :student => @portal_student, :remote_endpoint_url => "http://example.com/activities/1")
      allow(@learner).to receive(:update_last_run)
      allow(controller).to receive(:setup_portal_student).and_return(@learner)
      allow(Portal::Offering).to receive(:find).and_return(@offering)
      sign_in @user
    end

    it "saves learner data in the cookie and redirects to URL with additional params" do
      @runnable.append_learner_id_to_url = false
      @runnable_url = URI.parse(@runnable_opts[:url])
      @runnable_url.query = {
        :class_info_url => @clazz.class_info_url,
        :context_id => @offering.clazz.class_hash,
        :domain => @offering.domain,
        :domain_uid => @portal_student.user_id,
        :externalId => @learner.id,
        :logging => @offering.logging,
        :platform_id => APP_CONFIG[:site_url],
        :platform_user_id => @portal_student.user_id,
        :resource_link_id => @offering.id,
        :returnUrl => @learner.remote_endpoint_url
      }.to_query
      @redirect_url = @runnable_url.to_s

      get :show, params: { :id => @offering.id, :format => 'run_resource_html' }
      expect(response.cookies["save_path"]).to eq(@offering.runnable.save_path)
      expect(response.cookies["learner_id"]).to eq(@learner.id.to_s)
      expect(response.cookies["student_name"]).to eq("#{@user.first_name} #{@user.last_name}")
      expect(response.cookies["activity_name"]).to eq(@offering.runnable.name)
      expect(response.cookies["class_id"]).to eq(@clazz.id.to_s)

      expect(response).to redirect_to(@redirect_url)
    end

    it "appends the learner id to the url for resources without a tool" do
      @runnable.append_learner_id_to_url = true
      @runnable.tool_id = nil
      # @runnable.stub!(:append_learner_id_to_url).and_return(true)
      get :show, params: { :id => @offering.id, :format => 'run_resource_html' }
      expect(response).to redirect_to(@runnable_opts[:url] + "?learner=#{@learner.id}")
    end

    it "redirects to the url for Activity Player activities" do
      @ap_tool_opts = {
        :id => 2,
        :name => "Activity Player",
        :source_type => "Activity Player",
        :tool_id => "http://activityplayer.url/"
      }
      @ap_tool = FactoryBot.create(:tool, @ap_tool_opts)
      @ap_runnable_opts = {
        :name      => "Some Activity",
        :url       => "http://example.com",
        :save_path => "/path/to/save",
        :tool_id   => @ap_tool.id
      }
      @ap_runnable = FactoryBot.create(:external_activity, @ap_runnable_opts)
      @ap_offering = mock_model(Portal::Offering, :runnable => @ap_runnable, :clazz => @clazz)
      @ap_learner = mock_model(Portal::Learner, :id => 35, :offering => @ap_offering, :student => @portal_student)
      allow(@ap_learner).to receive(:update_last_run)
      allow(controller).to receive(:setup_portal_student).and_return(@ap_learner)
      allow(Portal::Offering).to receive(:find).and_return(@ap_offering)
      get :show, params: { :id => @ap_offering.id, :format => 'run_resource_html' }
      expect(response).to redirect_to(@ap_runnable_opts[:url])
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
      post :offering_collapsed_status, params: @params, xhr: true
      expect(response.body).to be_blank

      sign_in @manager_user
      post :offering_collapsed_status, params: @params, xhr: true
      expect(response.body).to be_blank

      sign_in @researcher_user
      post :offering_collapsed_status, params: @params, xhr: true
      expect(response.body).to be_blank

      sign_in @author_user
      post :offering_collapsed_status, params: @params, xhr: true
      expect(response.body).to be_blank

      sign_in @guest_user
      post :offering_collapsed_status, params: @params, xhr: true
      expect(response.body).to be_blank

      sign_in @student_user
      post :offering_collapsed_status, params: @params, xhr: true
      expect(response.body).to be_blank
    end
    it "should maintain the offering collapse expand status when user is a teacher" do
      sign_in @authorized_teacher_user
      #when teacher has never expanded or collapsed before
      portal_teacher_full_status = Portal::TeacherFullStatus.find_by_offering_id_and_teacher_id(@params[:id], @authorized_teacher.id)
      expect(portal_teacher_full_status).to be_nil

      # after first expand
      post :offering_collapsed_status, params: @params, xhr: true
      portal_teacher_full_status = Portal::TeacherFullStatus.find_by_offering_id_and_teacher_id(@params[:id], @authorized_teacher.id)
      expect(portal_teacher_full_status).not_to be_nil
      expect(portal_teacher_full_status.offering_collapsed).to eq(false)
      expect(response.body).to be_blank

      #when teacher has collapsed and expanded many times before
      post :offering_collapsed_status, params: @params, xhr: true
      portal_teacher_full_status.reload
      expect(portal_teacher_full_status).not_to be_nil
      expect(portal_teacher_full_status.offering_collapsed).to eq(true)
      expect(response.body).to be_blank
    end
  end

  describe "GET report" do
    let(:external_activity) { FactoryBot.create(:external_activity) }

    let(:offering) { FactoryBot.create(
        :portal_offering,
        runnable_id: external_activity.id,
        runnable_type: 'ExternalActivity',
        clazz: clazz)}

    let(:clazz)       { FactoryBot.create :portal_clazz, teachers: [teacher] }
    let(:post_params) { { id: offering.id } }
    let(:teacher)     { FactoryBot.create :teacher }
    let(:teacher_b)   { FactoryBot.create :teacher }

    before(:each) do
      sign_in user
    end

    describe "When the teacher of the class requests the default report" do
      let(:user)        { teacher.user }
      let(:report_url)  { "https://concord-consortium.github.io/portal-report/" }

      describe "when offering report is used" do
        before(:each) do
          # Ensure that default report is available.
          FactoryBot.create(:default_lara_report, { url: report_url })
        end

        it "should redirect to the default reporting service" do
          get :report, params: post_params
          expect(response.location).to match(/#{report_url}/)
        end
        it "should include an authentication token parameter" do
          get :report, params: post_params
          expect(response.location).to match(/token=([0-9]|[a-f]){32}/)
        end
        it "should include an authentication token parameter" do
          get :report, params: post_params
          expect(response.location).to match(/token=([0-9]|[a-f]){32}/)
        end
      end
    end

    describe "when the current user is a teacher without access to this offering" do
      let(:user) { teacher_b.user }
      it "should redirect the user to /recent_activity" do
        get :report, params: post_params
        expect(response).to redirect_to :recent_activity
      end
    end
  end

  describe '#student_report' do
    let(:external_activity) { FactoryBot.create(:external_activity) }
    let(:clazz)       { FactoryBot.create(:portal_clazz) }
    let(:offering)    { FactoryBot.create(:portal_offering, runnable: external_activity, clazz: clazz)}
    let(:post_params) { { id: offering.id } }
    let(:student)     { FactoryBot.create(:full_portal_student) }

    before(:each) do
      sign_in student.user
      student.clazzes << clazz
    end

    describe "When the student requests the default report" do
      let(:report_url)  { "https://concord-consortium.github.io/portal-report/" }

      describe "when offering report is used" do
        before(:each) do
          # Ensure that default report is available.
          FactoryBot.create(:default_lara_report, { url: report_url })
        end

        it "should redirect to the default reporting service" do
          get :student_report, params: post_params
          expect(response.location).to match(/#{report_url}/)
        end
        it "should provide studentId" do
          get :student_report, params: post_params
          expect(response.location).to include("studentId=#{student.user.id}")
        end
      end
    end
  end


  # TODO: auto-generated
  describe '#update' do
    it 'PATCH update' do
      put :update, params: { id: 1 }

      expect(response).to have_http_status(:not_found)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, params: { id: FactoryBot.create(:portal_offering).to_param }

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
      get :activate, params: { id: FactoryBot.create(:portal_offering).to_param }

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
      get :deactivate, params: { id: FactoryBot.create(:portal_offering).to_param }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#student_report' do
    it 'GET student_report' do
      get :student_report, params: { id: FactoryBot.create(:portal_offering).to_param }

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#external_report' do
    it 'GET external_report' do
      get :external_report, params: { id: FactoryBot.create(:portal_offering).to_param, report_id: 1 }

      expect(response).to have_http_status(:redirect)
    end
  end
end
