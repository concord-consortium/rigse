require File.expand_path('../../../spec_helper', __FILE__)

def runnable_params(runnable, clazz)
  post_params = {
    :runnable_id => runnable.id,
    :runnable_type => "ExternalActivity",
    :dragged_dom_id => "external_activity_#{runnable.id}",
    :dropped_dom_id => "clazz_offerings",
    :id => clazz.id
  }
end

describe Portal::ClazzesController do
  render_views

  def mock_clazz(stubs={})
    mock_clazz = FactoryBot.create(:portal_clazz, stubs) #mock_model(Portal::Clazz)
    #mock_clazz.stub!(stubs) unless stubs.empty?

    mock_clazz
  end

  def sign_in_symbol(user_sym)
    sign_in instance_variable_get("@#{user_sym}")
  end

  before(:each) do
    @mock_school = FactoryBot.create(:portal_school)

    # set up our user types
    @normal_user = FactoryBot.generate(:anonymous_user)
    @admin_user = FactoryBot.generate(:admin_user)
    @authorized_student =         FactoryBot.create(:portal_student, :user => FactoryBot.create(:confirmed_user, :login => "authorized_student"))
    @authorized_teacher =         FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:confirmed_user, :login => "authorized_teacher"), :schools => [@mock_school])
    @another_authorized_teacher = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:confirmed_user, :login => "another_authorized_teacher"), :schools => [@mock_school])
    @unauthorized_teacher =       FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:confirmed_user, :login => "unauthorized_teacher"), :schools => [@mock_school])
    # another teacher, to act as an arbitrary third party
    @random_teacher =             FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:confirmed_user, :login => "random_teacher"), :schools => [@mock_school])

    @authorized_teacher_user = @authorized_teacher.user
    @unauthorized_teacher_user = @unauthorized_teacher.user
    @authorized_student_user = @authorized_student.user


    @mock_clazz_name = "Random Test Class"
    @mock_course = FactoryBot.create(:portal_course, :name => @mock_clazz_name, :school => @mock_school)
    @mock_clazz = mock_clazz({ :name => @mock_clazz_name, :teachers => [@authorized_teacher, @another_authorized_teacher], :course => @mock_course, :students => [@authorized_student] })

    allow(@controller).to receive(:before_render) {
      allow(response.template).to receive_message_chain(:current_settings, :name).and_return("Test Settings")
    }
    @mock_settings = mock_model(Admin::Settings, :name => "Test Settings")
    allow(@mock_settings).to receive(:enable_grade_levels?).and_return(true)
    allow(@mock_settings).to receive(:allow_default_class).and_return(false)
    allow(@mock_settings).to receive(:use_student_security_questions).and_return(false)
    allow(@mock_settings).to receive(:require_user_consent?).and_return(false)
    allow(@mock_settings).to receive(:default_cohort).and_return(nil)
    allow(Admin::Settings).to receive(:default_settings).and_return(@mock_settings)
  end

  describe "GET show" do
    it "redirects the teacher to the class's materials page" do
      sign_in @authorized_teacher_user
      get :show, params: { :id => @mock_clazz.id }

      expect(response).to redirect_to("/portal/classes/#{@mock_clazz.id}/materials")
    end

    it "doesn't show class to unauthorized teacheruser" do
      sign_in @unauthorized_teacher_user
      get :show, params: { :id => @mock_clazz.id }

      expect(response).not_to be_successful
      expect(response).to redirect_to("/recent_activity")
    end

    it "shows student a list of class assignments" do
      sign_in @authorized_student_user
      get :show, params: { :id => @mock_clazz.id }

      expect(response).to be_successful
      expect(response.body).to have_content("Random Test Class")
    end
  end # end describe GET show

  describe "XMLHttpRequest edit" do
    it "doesn't show the details of a class to unauthorized teachers" do
      sign_in @unauthorized_teacher_user
      teachers = [@authorized_teacher, @random_teacher]
      @mock_clazz.teachers = teachers

      post :edit, params: {id: @mock_clazz.id}, xhr: true

      expect(response).not_to be_successful
    end

    it "should not allow me to modify the requested class's school" do
      login_admin
      post :edit, params: {id: @mock_clazz.id}, xhr: true

      assert_select("select[name=?]", "#{@mock_clazz.class.table_name.singularize}[school]", false)
    end

    def can_edit(teacher)
      assert_select("table.teachers_listing") do
        assert_select("input#clazz_teacher_#{teacher.id}:not([disabled='disabled'])")
      end
    end

    def cant_edit(teacher)
      assert_select("table.teachers_listing") do
        assert_select("input#clazz_teacher_#{teacher.id}[disabled='disabled']")
      end
    end

    describe "conditions for a user trying to remove a teacher from a class" do

      # TODO: Verify we are fine with preventing the current user from removing themselves.
      # it "this teacher is the last teacher assigned to this class" do
      #   # @mock_clazz should only have one teacher, but let's make sure
      #   teachers = [@authorized_teacher]
      #   @mock_clazz.teachers = teachers

      #   post :edit, params: {id: @mock_clazz.id}, xhr: true

      #   # There should be only one teacher listed, and it should not be enabled
      #   assert_select("div#teachers_listing") do
      #     assert_select("tr#portal__teacher_#{teachers.first.id}") do
      #       assert_select("img[src*='delete_grey.png'][title=?]", Portal::Clazz::ERROR_REMOVE_TEACHER_LAST_TEACHER)
      #     end
      #   end
      # end


    end
  end

  describe "POST create" do
    before(:each) do
      # Make sure we have the grade levels we want
      0.upto(12) do |num|
        grade = Portal::Grade.where(name: num.to_s).first_or_create
        grade.active = true
        grade.save!
      end

      @post_params = {
        :portal_clazz => {
          :name => "New Test Class",
          :class_word => "1020304050",
          :school => @mock_school.id,
          :description => "Test!",
          :teacher_id => @authorized_teacher.id,
          :grade_levels => {
            :"6" => "1",
            :"7" => "1",
            :"9" => "1"
          }
        }
      }
    end

    it "should create a new class, assigned to the correct teacher, in the correct school" do
      sign_in @authorized_teacher_user

      post :create, params: @post_params

      @mock_school.reload
      @authorized_teacher.reload

      @new_clazz = Portal::Clazz.find_by_class_word(@post_params[:portal_clazz][:class_word])

      assert @new_clazz
      expect(@new_clazz.school).to eq(@mock_school)
      expect(@authorized_teacher.clazzes).to include(@new_clazz)
      expect(@mock_school.clazzes).to include(@new_clazz)
    end

    it "should attach this class to the appropriate course in the specified school, if one exists" do
      course = FactoryBot.create(:portal_course, :name => @post_params[:portal_clazz][:name], :school => @mock_school)
      assert course
      expect(course.clazzes.size).to eq(0)

      sign_in @authorized_teacher_user

      post :create, params: @post_params

      course.reload

      @new_clazz = Portal::Clazz.find_by_class_word(@post_params[:portal_clazz][:class_word])

      expect(@new_clazz.course).to eq(course)
      expect(course.clazzes.size).to eq(1)
      expect(course.clazzes).to include(@new_clazz)
      expect(course.school.clazzes).to include(@new_clazz)
    end

    it "should create a new course in the specified school if this class has a unique name" do
      expect(Portal::Course.find_by_name(@post_params[:portal_clazz][:name])).to be_nil

      sign_in @authorized_teacher_user

      post :create, params: @post_params

      @mock_school.reload
      course = Portal::Course.find_by_name(@post_params[:portal_clazz][:name])

      assert course
      expect(@mock_school.courses).to include(course)
    end

    it "should create exactly one teacher object for the current user if the current user does not already have one" do
      @random_user = FactoryBot.create(:confirmed_user, :login => "random_user")
      sign_in @random_user

      expect(@random_user.portal_teacher).to be_nil
      current_count = Portal::Teacher.count

      @post_params[:portal_clazz][:teacher_id] = nil

      post :create, params: @post_params

      @random_user.reload

      expect(@random_user.portal_teacher).not_to be_nil
      expect(Portal::Teacher.count).to eq(current_count + 1)
    end

    it "should not let me create a class with no school" do
      sign_in @authorized_teacher_user

      current_count = Portal::Clazz.count

      @post_params[:portal_clazz][:school] = nil

      post :create, params: @post_params

      assert flash['error']
      expect(Portal::Clazz.count).to eq(current_count)
    end

    it "should assign the specified grade levels to the new class" do
      sign_in @authorized_teacher_user

      post :create, params: @post_params

      assert flash['notice']

      @new_clazz = Portal::Clazz.where(class_word: @post_params[:portal_clazz][:class_word]).first

      @post_params[:portal_clazz][:grade_levels].each do |name, v|
        grade = Portal::Grade.find_by_name(name.to_s)
        expect(@new_clazz.grades).to include(grade)
      end
    end

    it "should not let me create a class with no grade levels when grade levels are enabled" do
      sign_in @authorized_teacher_user

      current_count = Portal::Clazz.count

      @post_params[:portal_clazz][:grade_levels] = nil

      post :create, params: @post_params

      assert flash['error']
      expect(Portal::Clazz.count).to equal(current_count)
    end

    it "should let me create a class with no grade levels when grade levels are disabled" do
      allow(@mock_settings).to receive(:enable_grade_levels?).and_return(false)
      @post_params[:portal_clazz].delete(:grade_levels)

      sign_in @authorized_teacher_user

      current_count = Portal::Clazz.count

      post :create, params: @post_params

      expect(Portal::Clazz.count).to equal(current_count + 1)
    end
  end

  describe "PUT update" do
    before(:each) do
      # Make sure we have the grade levels we want
      0.upto(12) do |num|
        grade = Portal::Grade.where(name: num.to_s).first_or_create
        grade.active = true
        grade.save!
      end

      @teacher2 = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:confirmed_user, :login => "teacher_2"), :schools => [@mock_school])
      @teacher3 = FactoryBot.create(:portal_teacher, :user => FactoryBot.create(:confirmed_user, :login => "teacher_3"), :schools => [@mock_school])

      @post_params = {
        :id => @mock_clazz.id,
        :portal_clazz => {
          :name => "New Test Class",
          :class_word => "1020304050",
          :description => "Test!",
          :teacher_id => @authorized_teacher.id,
          :grade_levels => {
            :"6" => "1",
            :"7" => "1",
            :"9" => "1"
          },
          :current_teachers => [
            @authorized_teacher.id,
            @teacher2.id,
            @teacher3.id,
          ].join(",")
        }
      }
    end

    it "should not let me update a class with no grade levels when grade levels are enabled" do
      sign_in @authorized_teacher_user

      @post_params[:portal_clazz][:grade_levels] = nil

      put :update, params: @post_params

      assert flash['error']
    end

    it "should let me update a class with no grade levels when grade levels are disabled" do
      allow(@mock_settings).to receive(:enable_grade_levels?).and_return(false)
      @post_params[:portal_clazz].delete(:grade_levels)

      sign_in @authorized_teacher_user

      # the change of class name should trigger an update of the report model cache of the class
      expect_any_instance_of(Portal::Clazz).to receive(:update_report_model_cache)

      put :update, params: @post_params

      expect(Portal::Clazz.find(@mock_clazz.id).name).to eq('New Test Class')
    end

    it "should let me change the teachers" do
      expect(Portal::Clazz.find(@mock_clazz.id).teachers).to eq([
        @authorized_teacher, @another_authorized_teacher
      ])
      sign_in @authorized_teacher_user

      # without a name change the change of teachers should trigger an update of the report model cache of the class
      original_name = @mock_clazz.name
      @post_params[:portal_clazz][:name] = @mock_clazz.name
      expect_any_instance_of(Portal::Clazz).to receive(:update_report_model_cache)

      put :update, params: @post_params
      expect(Portal::Clazz.find(@mock_clazz.id).teachers).to eq([
        @authorized_teacher, @teacher2, @teacher3
      ])

      expect(Portal::Clazz.find(@mock_clazz.id).name).to eq(original_name)
    end

    it "should not trigger a report model cache update when the name or teachers do not change" do
      expect(Portal::Clazz.find(@mock_clazz.id).teachers).to eq([
        @authorized_teacher, @another_authorized_teacher
      ])
      sign_in @authorized_teacher_user

      # remove the name and teacher updates to ensure the report model cache update is skipped
      original_name = @mock_clazz.name
      @post_params[:portal_clazz][:name] = @mock_clazz.name
      @post_params[:portal_clazz][:current_teachers] = @mock_clazz.teachers.map {|t| t.id}.join(",")
      expect_any_instance_of(Portal::Clazz).not_to receive(:update_report_model_cache)

      put :update, params: @post_params

      expect(Portal::Clazz.find(@mock_clazz.id).name).to eq(original_name)
    end
  end

  describe "Post edit class information" do
    before(:each) do
      offers = Array.new
      @mock_clazz.offerings.each do|offering|
        offers << offering.id.to_s
      end

      @post_params = {
          :id => @mock_clazz.id,
          :portal_clazz => {
            :name => 'electrical engineering circuits and system',
            :class_word => 'EECS',
            :description => 'Test!',
            :teacher_id => @authorized_teacher.id.to_s,
            :grade_levels => {
              :"6" => "1",
              :"7" => "1",
              :"9" => "1"
            }
          },
          :clazz_investigations_ids => offers,
          :clazz_active_investigations => offers,
          :clazz_teacher_ids => (@authorized_teacher.id.to_s + "," + @another_authorized_teacher.id.to_s)
        }

    end

    it "should not save the edited class info if the class name is blank" do
      login_admin
      @post_params[:portal_clazz][:name] = ''
      post :update, params: @post_params
      @portal_clazz = Portal::Clazz.find_by_id(@post_params[:id])
      expect(@portal_clazz.name).not_to eq(''), 'Class saved with no name.'
    end

    it "should not save the edited class info if the class word is blank" do
      login_admin
      @post_params[:portal_clazz][:class_word] = ''
      post :update, params: @post_params
      @portal_clazz = Portal::Clazz.find_by_id(@post_params[:id])
      expect(@portal_clazz.class_word).not_to eq(''), 'Class saved with blank class word.'
    end
  end

  # GET manage_classes
  describe "GET manage_classes" do

    it "saves the position of the left pane submenu item for an authorized teacher" do
      sign_in @authorized_teacher_user

      get :manage_classes

      expect(assigns(:teacher)).to eq @authorized_teacher
    end

  end

  # GET edit
  describe "GET edit" do

    it "saves the position of the left pane submenu item for an authorized teacher" do
      sign_in @authorized_teacher_user

      get :edit, params: { :id => @mock_clazz.id }

      # All users should see the full class details summary
      @authorized_teacher.reload
      expect(@authorized_teacher.left_pane_submenu_item).to eq(Portal::Teacher.LEFT_PANE_ITEM['CLASS_SETUP'])
    end

  end

  # GET materials
  describe "GET materials" do

    it "saves the position of the left pane submenu item for an authorized teacher" do
      sign_in @authorized_teacher_user

      get :materials, params: { :id => @mock_clazz.id }

      # All users should see the full class details summary
      @authorized_teacher.reload
      expect(@authorized_teacher.left_pane_submenu_item).to eq(Portal::Teacher.LEFT_PANE_ITEM['MATERIALS'])
    end

  end

  # GET roster
  describe "GET roster" do

    it "saves the position of the left pane submenu item for an authorized teacher" do
      sign_in @authorized_teacher_user

      get :roster, params: { :id => @mock_clazz.id }

      # All users should see the full class details summary
      @authorized_teacher.reload
      expect(@authorized_teacher.left_pane_submenu_item).to eq(Portal::Teacher.LEFT_PANE_ITEM['STUDENT_ROSTER'])
    end

  end


  describe "Post teacher sorts class offerings on class summary page" do
    before(:each) do
      @physics_offering = FactoryBot.create(:portal_offering)
      @chemistry_offering = FactoryBot.create(:portal_offering)
      @biology_offering = FactoryBot.create(:portal_offering)
      @mathematics_offering = FactoryBot.create(:portal_offering)
      @params = {
        :clazz_offerings => [@physics_offering.id, @chemistry_offering.id, @biology_offering.id , @mathematics_offering.id]
      }
      sign_in @authorized_teacher_user
    end
    it "should store position of all the offerings after teacher sorts offerings" do

      # Save initial offering positions
      post :sort_offerings, params: @params, xhr: true
      offerings = Portal::Offering.where(:id => @params[:clazz_offerings])
      offerings.each do |offering|
        expect(offering.position ).to eq(@params[:clazz_offerings].index(offering.id) + 1)
      end

      # Update offering positions and verify they have been updated
      @params[:clazz_offerings] = [@mathematics_offering.id, @biology_offering.id, @chemistry_offering.id, @physics_offering.id]
      post :sort_offerings, params: @params, xhr: true
      offerings = Portal::Offering.where(:id => @params[:clazz_offerings])
      offerings.each do |offering|
        expect(offering.position ).to eq(@params[:clazz_offerings].index(offering.id) + 1)
      end
    end
  end

  describe "GET fullstatus" do
    before(:each) do
      @params = {
        :id => @mock_clazz.id
      }
    end
    it "should not allow access for anonymous user" do
      sign_out :user
      get :fullstatus, params: @params
      expect(response).not_to be_successful
    end
    it "should retrieve the class when user is not anonymous user" do
      sign_in @authorized_teacher_user
      get :fullstatus, params: @params
      expect(assigns[:portal_clazz]).to eq(@mock_clazz)
      expect(response).to be_successful
      expect(response).to render_template("fullstatus")
    end
  end

  # TODO: auto-generated
  describe '#current_clazz' do
    it 'GET current_clazz' do
      get :current_clazz, params: { id: 0 }

      expect(response).to have_http_status(:not_found)
    end
  end

end
