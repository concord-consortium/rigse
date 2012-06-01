require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::ClazzesController do
  render_views

  def setup_for_repeated_tests
    @controller = Portal::ClazzesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    # cleanup after previous tests
    Portal::Teacher.destroy_all
    Portal::Course.destroy_all
    Portal::Clazz.destroy_all
    Portal::School.destroy_all
    Portal::Semester.destroy_all
    User.destroy_all

    @mock_semester = Factory.create(:portal_semester, :name => "Fall")
    @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])

    # set up our user types
    @normal_user = Factory.next(:anonymous_user)
    @admin_user = Factory.next(:admin_user)
    @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "authorized_teacher"), :schools => [@mock_school])
    @another_authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "another_authorized_teacher"), :schools => [@mock_school])
    @unauthorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "unauthorized_teacher"), :schools => [@mock_school])

    @authorized_teacher_user = @authorized_teacher.user
    @unauthorized_teacher_user = @unauthorized_teacher.user

    # another teacher, to act as an arbitrary third party
    @random_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "random_teacher"), :schools => [@mock_school])

    @mock_clazz_name = "Random Test Class"
    @mock_course = Factory.create(:portal_course, :name => @mock_clazz_name, :school => @mock_school)
    @mock_clazz = mock_clazz({ :name => @mock_clazz_name, :teachers => [@authorized_teacher, @another_authorized_teacher], :course => @mock_course })

    @controller.stub(:before_render) {
      response.template.stub_chain(:current_project, :name).and_return("Test Project")
    }
    @mock_project = mock_model(Admin::Project, :name => "Test Project")
    @mock_project.stub(:enable_grade_levels?).and_return(true)
    @mock_project.stub(:maven_jnlp_family).and_return(nil)
    @mock_project.stub(:snapshot_enabled).and_return(false)
    @mock_project.stub(:allow_default_class).and_return(false)
    @mock_project.stub(:use_student_security_questions).and_return(false)
    Admin::Project.stub(:default_project).and_return(@mock_project)
  end

  # def login_as(user_sym)
  #     @logged_in_user = instance_variable_get("@#{user_sym.to_s}")
  #
  #     @controller.stub!(:current_user).and_return(@logged_in_user)
  #     @logged_in_user
  #   end

  def mock_clazz(stubs={})
    mock_clazz = Factory.create(:portal_clazz, stubs) #mock_model(Portal::Clazz)
    #mock_clazz.stub!(stubs) unless stubs.empty?

    mock_clazz
  end

  before(:each) do
    setup_for_repeated_tests
    stub_current_user :admin_user # Make admin our default test user
  end


  describe "GET show" do
    it "assigns the requested class as @portal_clazz" do
      get :show, :id => @mock_clazz.id
      assigns[:portal_clazz].should == @mock_clazz
    end

    it "doesn't show class to unauthorized teacheruser" do
      stub_current_user :unauthorized_teacher_user
      get :show, { :id => @mock_clazz.id }

      response.should_not be_success
      response.should redirect_to("/home")
    end

    it "shows the full class summary, with edit button if current user is authorized" do
      [:admin_user, :authorized_teacher_user].each do |user|
        setup_for_repeated_tests
        stub_current_user user

        get :show, { :id => @mock_clazz.id }

        # All users should see the full class details summary
        assert_select("div#details_portal__clazz_#{@mock_clazz.id}") do
          assert_select('div.action_menu') do
            assert_select('a', :text => 'edit class information')
          end
        end
      end
    end

    it "shows the list of all teachers assigned to the requested class" do
      teachers = [@authorized_teacher, @random_teacher]
      @mock_clazz.teachers = teachers

      get :show, :id => @mock_clazz.id

      assert_select("div.block_list") do
        assert_select("ul") do
          teachers.each do |teacher|
            assert_select("li", :text => /#{teacher.name}/)
          end
        end
      end
    end
  end # end describe GET show

  describe "XMLHttpRequest edit" do
    it "doesn't show the details of a class to unauthorized teachers" do
      stub_current_user :unauthorized_teacher_user
      teachers = [@authorized_teacher, @random_teacher]
      @mock_clazz.teachers = teachers

      xml_http_html_request :post, :edit, :id => @mock_clazz.id
      
      response.should_not be_success
    end

    [:admin_user, :authorized_teacher_user].each do |user|
      it "shows the details of all teachers assigned to the requested class with removal links to #{user}" do
        setup_for_repeated_tests
        stub_current_user user

        teachers = [@authorized_teacher, @random_teacher]
        @mock_clazz.teachers = teachers
        
        
        xml_http_html_request :post, :edit, :id => @mock_clazz.id

        response.content_type.should == "text/html"

        # All users should see the list of current teachers
        assert_select("div#teachers_listing") do
          teachers.each do |teacher|
            assert_select("tr#portal__teacher_#{teacher.id}") do |e|
              assert_select("img[src*='delete']")
            end
          end
        end
      end
    end

    it "should not allow me to modify the requested class's school" do
      xml_http_request :post, :edit, :id => @mock_clazz.id

      assert_select("select[name=?]", "#{@mock_clazz.class.table_name.singularize}[school]", false)
    end

    describe "conditions for a user trying to remove a teacher from a class" do
      it "the user is allowed to remove any teacher in the list" do
        teachers = [@authorized_teacher, @random_teacher]
        @mock_clazz.teachers = teachers

        xml_http_html_request :post, :edit, :id => @mock_clazz.id

        assert_select("div#teachers_listing") do
          teachers.each do |teacher|
            assert_select("tr#portal__teacher_#{teacher.id}") do
              assert_select("a.rollover[onclick*=?]", remove_teacher_portal_clazz_path(@mock_clazz.id, :teacher_id => teacher.id)) do
                assert_select("img[src*='delete.png']")
              end
            end
          end
        end
      end

      it "this teacher is the last teacher assigned to this class" do
        # @mock_clazz should only have one teacher, but let's make sure
        teachers = [@authorized_teacher]
        @mock_clazz.teachers = teachers

        xml_http_html_request :post, :edit, :id => @mock_clazz.id

        # There should be only one teacher listed, and it should not be enabled
        assert_select("div#teachers_listing") do
          assert_select("tr#portal__teacher_#{teachers.first.id}") do
            assert_select("img[src*='delete_grey.png'][title=?]", Portal::Clazz::ERROR_REMOVE_TEACHER_LAST_TEACHER)
          end
        end
      end

      # REMOVED -- teachers can remove themselves, but will be immediately redirected away from the edit page.
      # it "this teacher is the current user" do
      #   login_as :authorized_teacher_user
      #
      #   teachers = [@authorized_teacher, @random_teacher]
      #   @mock_clazz.teachers = teachers
      #
      #   xml_http_request :post, :edit, :id => @mock_clazz.id
      #
      #   # Only the current user's teacher should be disabled; all others should be enabled
      #   assert_select("div#teachers_listing") do
      #     teachers.each do |teacher|
      #       assert_select("tr#portal__teacher_#{teacher.id}") do
      #         if teacher.user == @logged_in_user
      #           assert_select("img[src*='delete_grey.png'][title=?]", Portal::Clazz::ERROR_REMOVE_TEACHER_CURRENT_USER)
      #         else
      #           assert_select("a.rollover[onclick*=?]", remove_teacher_portal_clazz_path(@mock_clazz.id, :teacher_id => teacher.id)) do
      #             assert_select("img[src*='delete.png']")
      #           end
      #         end
      #       end
      #     end
      #   end
      # end

      it "this teacher is the current user" do
        stub_current_user :authorized_teacher_user

        teachers = [@authorized_teacher, @random_teacher]
        @mock_clazz.teachers = teachers

        xml_http_html_request :post, :edit, :id => @mock_clazz.id

        # The current user's teacher should produce a different warning message on click; all
        # others should use the default confirm text. All users' delete links should be enabled.
        assert_select("div#teachers_listing") do
          teachers.each do |teacher|
            assert_select("tr#portal__teacher_#{teacher.id}") do
              assert_select("a.rollover[onclick*=?]", remove_teacher_portal_clazz_path(@mock_clazz.id, :teacher_id => teacher.id)) do |elem|
                assert_select("img[src*='delete.png']")

                warning_str = Portal::Clazz.WARNING_REMOVE_TEACHER_CURRENT_USER(@mock_clazz.name).gsub(/(\\|<\/|\r\n|[\n\r"'])/) do
                  ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP[$1]
                end
                confirm_str = Portal::Clazz.CONFIRM_REMOVE_TEACHER(teacher.name, @mock_clazz.name).gsub(/(\\|<\/|\r\n|[\n\r"'])/) do
                  ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP[$1]
                end

                if teacher.user == @logged_in_user
                  elem.to_s.should include(warning_str)
                  elem.to_s.should_not include(confirm_str)
                else
                  elem.to_s.should include(confirm_str)
                  elem.to_s.should_not include(warning_str)
                end
              end
            end
          end
        end
      end
    end

    [:admin_user, :authorized_teacher_user, :unauthorized_teacher_user].each do |user|
      if user == :unauthorized_teacher_user
        does_this = "does not populate the list of available teachers for ADD functionality if current user is unauthorized"
      else
        does_this = "populates the list of available teachers for ADD functionality if current user is a #{user}"
      end
      it does_this do
        setup_for_repeated_tests
        stub_current_user user

        1.upto 10 do |i|
          teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher#{i}"))
          @mock_clazz.school.portal_teachers << teacher
        end

        xml_http_html_request :post, :edit, :id => @mock_clazz.id

        if user == :unauthorized_teacher_user
          assert_select("select#teacher_id_selector[name=teacher_id]", false, 
            "Unauthorized users should not see the 'add teacher' dropdown")
        else
          assert_select("select#teacher_id_selector[name=teacher_id]") do |elem|
            assert_select("option[value=#{@authorized_teacher.id}]", false,
              "cannot add teachers who are already assigned to this class")

            @mock_clazz.school.portal_teachers.reject { |t| t.id == @authorized_teacher.id }.each do |t|
              assert_select("option[value='#{t.id}']")
            end
          end
        end
      end
    end
  end

  describe "POST add_teacher" do
    it "will add the selected teacher to the given class if the current user is authorized" do
      # @id
      # @teacher_id
      [:admin_user, :authorized_teacher_user, :unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        stub_current_user user

        post :add_teacher, { :id => @mock_clazz.id, :teacher_id => @unauthorized_teacher.id }

        @mock_clazz.reload

        if user == :unauthorized_teacher_user
          # Unauthorized users cannot add teachers, and will receive an error message
          assert !@mock_clazz.teachers.include?(@unauthorized_teacher)
          assert @response.body.include?(Portal::Clazz::ERROR_UNAUTHORIZED)
        else
          # Authorized users can add teachers
          assert @mock_clazz.teachers.include?(@unauthorized_teacher)
        end
      end
    end
  end

  describe "DELETE remove_teacher" do
    it "will remove the selected teacher from the given class if the current user is authorized" do
      # @id
      # @teacher_id
      [:admin_user, :authorized_teacher_user, :unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        stub_current_user user

        teachers = [@authorized_teacher, @random_teacher] # Any teachers except for @unauthorized_teacher will work here
        @mock_clazz.teachers = teachers

        delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => teachers.first.id }

        @mock_clazz.reload

        if user == :unauthorized_teacher_user
          # Unauthorized users cannot remove teachers, and will receive an error message
          assert @mock_clazz.teachers.include?(teachers.first)
          assert @response.body.include?(Portal::Clazz::ERROR_UNAUTHORIZED)
        else
          # Authorized users can remove teachers
          assert !@mock_clazz.teachers.include?(teachers.first)
        end
      end
    end

    it "will not let me remove the last teacher from the given class" do
      #remove one teacher
      delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => @another_authorized_teacher.id }
      
      #remove last teacher
      delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => @authorized_teacher.id }

      @mock_clazz.reload

      assert @mock_clazz.teachers.include?(@authorized_teacher)
      assert @response.body.include?(Portal::Clazz::ERROR_REMOVE_TEACHER_LAST_TEACHER)
    end

    it "will disable the remaining delete button if there is only one remaining teacher after this operation" do
      teachers = [@authorized_teacher, @random_teacher]
      @mock_clazz.teachers = teachers

      delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => @authorized_teacher.id }

      assert_select("tr#portal__teacher_#{@random_teacher.id}") do
        assert_select("img[src*='delete_grey.png'][title=?]", Portal::Clazz::ERROR_REMOVE_TEACHER_LAST_TEACHER)
      end
    end

    # REMOVED -- we now redraw the entire teacher listing each time a teacher is removed, in case the delete permissions change between operations.
    # it "will remove a teacher listing with JavaScript if there is more than one remaining teacher after this operation" do
    #   teachers = [@authorized_teacher, @unauthorized_teacher, @random_teacher]
    #   @mock_clazz.teachers = teachers
    #
    #   delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => @authorized_teacher.id }
    #
    #   without_tag("tr") # All teacher listings are in table rows; we shouldn't be actually rendering any HTML content here.
    # end

    it "will re-render the teacher listing when a teacher is removed" do
      teachers = [@authorized_teacher, @unauthorized_teacher, @random_teacher]
      @mock_clazz.teachers = teachers

      delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => @authorized_teacher.id }

      assert_select("tr#portal__teacher_#{@unauthorized_teacher.id}")
      assert_select("tr#portal__teacher_#{@random_teacher.id}")
      assert_select("tr#portal__teacher_#{@authorized_teacher.id}", false)
    end

    it "will redirect the user to their home page if they remove themselves from a class" do
      [:authorized_teacher_user, :unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        stub_current_user user

        teachers = [@authorized_teacher, @unauthorized_teacher]
        @mock_clazz.teachers = teachers

        delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => @authorized_teacher.id }

        if user == :authorized_teacher_user
          @response.body.should include(home_url)
        else
          @response.body.should_not include(home_url)
        end
      end
    end
  end

  describe "GET new" do
    it "should show a list of the current teacher's schools to which to assign this class" do
      stub_current_user :authorized_teacher_user

      get :new

      assert_select("select[name=?]", "#{@mock_clazz.class.table_name.singularize}[school]") do
        @logged_in_user.portal_teacher.schools.each do |school|
          assert_select("option[value='#{school.id}']", :text => school.name)
        end
      end
    end

    it "should show a check box for each possible site grade level" do
      stub_current_user :authorized_teacher_user

      get :new

      APP_CONFIG[:active_grades].each do |name|
        assert_select("input[type='checkbox'][name=?]", "portal_clazz[grade_levels][#{name}]")
      end
    end

    it "should populate the schools list with the project default school if the current user does not belong to any schools" do
      [:admin_user, :authorized_teacher_user].each do |user|
        setup_for_repeated_tests
        stub_current_user user

        get :new

        assert_select("select[name=?]", "#{@mock_clazz.class.table_name.singularize}[school]") do
          school = Portal::School.find_by_name(APP_CONFIG[:site_school])
          assert_select("option[value='#{school.id}']", :text => school.name)
          assert_select("option", :count => 1)
        end
      end
    end

    # REMOVED -- teachers must create the class before being able to add teachers.
    # it "populates the list of available teachers for ADD functionality" do
    #   login_as :authorized_teacher_user
    #
    #   1.upto 10 do |i|
    #     teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher#{i}"))
    #     @logged_in_user.portal_teacher.school.portal_teachers << teacher
    #   end
    #
    #   get :new
    #
    #   assert_select("select#teacher_id_selector[name=teacher_id]") do |elem|
    #     without_tag("option[value=?]", @logged_in_user.portal_teacher.id) # cannot add teachers who are already assigned to this class
    #
    #     @logged_in_user.portal_teacher.school.portal_teachers.reject { |t| t.id == @logged_in_user.portal_teacher.id }.each do |t|
    #       assert_select("option[value=?]", t.id)
    #     end
    #   end
    # end
  end # end describe "GET new"

  describe "POST create" do
    before(:each) do
      # Make sure we have the grade levels we want
      0.upto(12) do |num|
        grade = Portal::Grade.find_or_create_by_name(num.to_s)
        grade.active = true
        grade.save
      end

      @post_params = {
        :portal_clazz => {
          :name => "New Test Class",
          :class_word => "1020304050",
          :school => @mock_school.id,
          :semester_id => @mock_semester.id,
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
      stub_current_user :authorized_teacher_user

      post :create, @post_params

      @mock_school.reload
      @authorized_teacher.reload

      @new_clazz = Portal::Clazz.find_by_class_word(@post_params[:portal_clazz][:class_word])

      assert @new_clazz
      @new_clazz.school.should == @mock_school
      @authorized_teacher.clazzes.should include(@new_clazz)
      @mock_school.clazzes.should include(@new_clazz)
    end

    it "should attach this class to the appropriate course in the specified school, if one exists" do
      course = Factory.create(:portal_course, :name => @post_params[:portal_clazz][:name], :school => @mock_school)
      assert course
      course.clazzes.size.should == 0

      stub_current_user :authorized_teacher_user

      post :create, @post_params

      course.reload

      @new_clazz = Portal::Clazz.find_by_class_word(@post_params[:portal_clazz][:class_word])

      @new_clazz.course.should == course
      course.clazzes.size.should == 1
      course.clazzes.should include(@new_clazz)
      course.school.clazzes.should include(@new_clazz)
    end

    it "should create a new course in the specified school if this class has a unique name" do
      assert_nil Portal::Course.find_by_name(@post_params[:portal_clazz][:name])

      stub_current_user :authorized_teacher_user

      post :create, @post_params

      @mock_school.reload
      course = Portal::Course.find_by_name(@post_params[:portal_clazz][:name])

      assert course
      @mock_school.courses.should include(course)
    end

    it "should create exactly one teacher object for the current user if the current user does not already have one" do
      @random_user = Factory.create(:user, :login => "random_user")
      stub_current_user :random_user

      assert_nil @logged_in_user.portal_teacher
      current_count = Portal::Teacher.count(:all)

      @post_params[:portal_clazz][:teacher_id] = nil

      post :create, @post_params

      @logged_in_user.reload

      assert_not_nil @logged_in_user.portal_teacher
      Portal::Teacher.count(:all).should == current_count + 1
    end

    it "should not let me create a class with no school" do
      stub_current_user :authorized_teacher_user

      current_count = Portal::Clazz.count(:all)

      @post_params[:portal_clazz][:school] = nil

      post :create, @post_params

      assert flash[:error]
      Portal::Clazz.count(:all).should == current_count
    end

    it "should assign the specified grade levels to the new class" do
      stub_current_user :authorized_teacher_user

      post :create, @post_params

      @new_clazz = Portal::Clazz.find_by_class_word(@post_params[:portal_clazz][:class_word])

      @post_params[:portal_clazz][:grade_levels].each do |name, v|
        grade = Portal::Grade.find_by_name(name.to_s)
        @new_clazz.grades.should include(grade)
      end
    end

    it "should not let me create a class with no grade levels when grade levels are enabled" do
      stub_current_user :authorized_teacher_user

      current_count = Portal::Clazz.count(:all)

      @post_params[:portal_clazz][:grade_levels] = nil

      post :create, @post_params

      assert flash[:error]
      Portal::Clazz.count(:all).should == current_count
    end

    it "should let me create a class with no grade levels when grade levels are disabled" do
      @mock_project.stub(:enable_grade_levels?).and_return(false)
      @post_params[:portal_clazz].delete(:grade_levels)

      stub_current_user :authorized_teacher_user

      current_count = Portal::Clazz.count(:all)

      post :create, @post_params

      Portal::Clazz.count(:all).should == (current_count + 1)
    end
  end
  
  describe "PUT update" do
    before(:each) do
      # Make sure we have the grade levels we want
      0.upto(12) do |num|
        grade = Portal::Grade.find_or_create_by_name(num.to_s)
        grade.active = true
        grade.save
      end

      setup_for_repeated_tests

      @post_params = {
        :id => @mock_clazz.id,
        :portal_clazz => {
          :name => "New Test Class",
          :class_word => "1020304050",
          :semester_id => @mock_semester.id,
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

    it "should not let me update a class with no grade levels when grade levels are enabled" do
      stub_current_user :authorized_teacher_user

      @post_params[:portal_clazz][:grade_levels] = nil

      put :update, @post_params

      assert flash[:error]
    end

    it "should let me update a class with no grade levels when grade levels are disabled" do
      @mock_project.stub(:enable_grade_levels?).and_return(false)
      @post_params[:portal_clazz].delete(:grade_levels)

      stub_current_user :authorized_teacher_user

      put :update, @post_params

      Portal::Clazz.find(@mock_clazz.id).name.should == 'New Test Class'
    end
  end
  
  describe "POST add_offering" do
    it "should run without error" do
      setup_for_repeated_tests
      page = Factory.create(:page)
      post_params = {
        :runnable_id => page.id, 
        :runnable_type => "page", 
        :dragged_dom_id => "page_#{page.id}", 
        :dropped_dom_id => "clazz_offerings",
        :id => @mock_clazz.id
      }
      
      post :add_offering, post_params
    end
  end

  
  describe "Post edit class information" do
    before(:each) do
      setup_for_repeated_tests
      page = Factory.create(:page)
      post_params = {
        :runnable_id => page.id, 
        :runnable_type => "page", 
        :dragged_dom_id => "page_#{page.id}", 
        :dropped_dom_id => "clazz_offerings",
        :id => @mock_clazz.id
      }
    
      post :add_offering, post_params
      offers = Array.new
      @mock_clazz.offerings.each do|offering|
        offers << offering.id.to_s
      end
      
      @post_params = {
          :id => @mock_clazz.id,
          :portal_clazz => {
            :name => 'electrical engineering circuits and system',
            :class_word => 'EECS',
            :semester_id => @mock_semester.id,
            :description => 'Test!',
            :teacher_id => @authorized_teacher.id.to_s,
            :grade_levels => {
              :"6" => "1",
              :"7" => "1",
              :"9" => "1"
            }
          },
          :clazz_investigations => offers,
          :clazz_investigations_hidden => offers,
          :clazz_teacher_ids => (@authorized_teacher.id.to_s + "," + @another_authorized_teacher.id.to_s)
        }
        
    end
    
    
    

    it "should not save the edited class info if the class name is blank" do
      @post_params[:portal_clazz][:name] = ''
      post :update, @post_params
      @portal_clazz = Portal::Clazz.find_by_id(@post_params[:id])
      assert_not_equal(@portal_clazz.name , '', 'Class saved with no name.')
    end
    
    it "should not save the edited class info if the class word is blank" do
      @post_params[:portal_clazz][:class_word] = ''
      post :update, @post_params
      @portal_clazz = Portal::Clazz.find_by_id(@post_params[:id])
      assert_not_equal(@portal_clazz.class_word , '', 'Class saved with blank class word.')
    end  
    
    it "should not update the class info if there is no teacher" do
      @post_params[:clazz_teacher_ids] = ''
      xhr :post, :edit_teachers, @post_params
      assert_equal(flash[:notice], 'There should be atleast one teacher assigned to the class.')
    end
    
    it "all the deactivated offerings should actually get deactivated in the database" do
      #active_offering = @mock_clazz.offerings[0]
      @post_params[:clazz_investigations] = Array[]
      post :update, @post_params
      
      @mock_clazz.reload
      
      @mock_clazz.offerings.each do |offering|
        assert_equal(offering.active, false)
      end
    end
    
    it "all newly assigned teachers and teachers removed from the class should be updated in the database" do
      @yet_another_authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "yet_another_authorized_teacher"), :schools => [@mock_school])
      @post_params[:clazz_teacher_ids] = @authorized_teacher.id.to_s + "," + @yet_another_authorized_teacher.id.to_s
      xhr :post, :edit_teachers, @post_params
      
      @authorized_teacher.reload
      @another_authorized_teacher.reload
      @yet_another_authorized_teacher.reload
      
      assert_not_nil(@authorized_teacher.clazzes.find_by_id(@mock_clazz.id))
      assert_nil(@another_authorized_teacher.clazzes.find_by_id(@mock_clazz.id))
      assert_not_nil(@yet_another_authorized_teacher.clazzes.find_by_id(@mock_clazz.id))
      
    end
  end
end