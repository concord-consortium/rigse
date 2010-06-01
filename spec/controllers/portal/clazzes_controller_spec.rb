require 'spec_helper'

describe Portal::ClazzesController do
  integrate_views
  
  def setup_for_repeated_tests
    @controller = Portal::ClazzesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    
    # cleanup after previous tests
    Portal::Teacher.destroy_all
    Portal::Course.destroy_all
    Portal::Clazz.destroy_all
    Portal::School.destroy_all
    User.destroy_all
    
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    
    # set up our user types
    @normal_user = Factory.next(:anonymous_user)
    @admin_user = Factory.next(:admin_user)
    @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "authorized_teacher"))
    @unauthorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "unauthorized_teacher"))
    
    @authorized_teacher_user = @authorized_teacher.user
    @unauthorized_teacher_user = @unauthorized_teacher.user
    
    @mock_course = Factory.create(:portal_course)
    @mock_clazz = mock_clazz({ :teachers => [@authorized_teacher], :course => @mock_course })
  end
  
  def login_as(user_sym)
    #user = user.user if user.is_a?(Portal::Teacher)
    user = instance_variable_get("@#{user_sym.to_s}")
    
    @controller.stub!(:current_user).and_return(user)
    user
  end

  def mock_clazz(stubs={})
    mock_clazz = Factory.create(:portal_clazz, stubs) #mock_model(Portal::Clazz)
    #mock_clazz.stub!(stubs) unless stubs.empty?
    mock_clazz
      # 
      # @mock_school.stub!(stubs) unless stubs.empty?
      # @mock_school
  end
  
  #describe "as administrator" do
  before(:each) do
    setup_for_repeated_tests
    login_as :admin_user
    
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end

  describe "GET show" do
    it "assigns the requested class as @portal_clazz" do
      #mock_object = mock_clazz({ :teachers => [Factory.create(:portal_teacher)] })
      #mock_id = mock_object.id
    
      get :show, :id => @mock_clazz.id
      assigns[:portal_clazz].should == @mock_clazz
    end
    
    it "shows the full class summary with edit button if current user is authorized" do
      [:admin_user, :authorized_teacher_user].each do |user|
        setup_for_repeated_tests
        login_as user
        
        get :show, { :id => @mock_clazz.id }

        with_tag("div#details_portal__clazz_#{@mock_clazz.id}") do
          with_tag('div.action_menu') do
            with_tag('div.action_menu_right') do
              with_tag('a', :text => 'edit')
            end
          end
        end
      end
      
      [:unauthorized_teacher_user].each do |user|
        setup_for_repeated_tests
        login_as user
        
        get :show, :id => @mock_clazz.id
      
        with_tag("div#details_portal__clazz_#{@mock_clazz.id}") do
          with_tag('div.action_menu') do
            with_tag('div.action_menu_right') do
              without_tag('a', :text => 'edit')
            end
          end
        end
      end
    end
    
    it "shows the list of all teachers assigned to the requested class, with removal link if current user is authorized" do
      teachers = [@authorized_teacher, @unauthorized_teacher]
      @mock_clazz.teachers = teachers
      
      get :show, :id => @mock_clazz.id
              
      with_tag("div#teachers_listing") do
        teachers.each do |teacher|
          with_tag("tr#portal__teacher_#{teacher.id}") do
            with_tag("a[onclick*=?]", remove_teacher_portal_clazz_path(@mock_clazz.id, :teacher_id => teacher.id))
          end
        end
      end
    end
    
    it "populates the list of available teachers for ADD functionality if current user is authorized" do
      1.upto 10 do |i|
        teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher#{i}"))
        @mock_course.school.portal_teachers << teacher
      end
      
      get :show, :id => @mock_clazz.id
              
      with_tag("select#teacher_id_selector[name=teacher_id]") do
        without_tag("option[value=?]", @authorized_teacher.id) # cannot add teachers who are already assigned to this class
        
        @mock_course.school.portal_teachers.each do |t|
          with_tag("option[value=?]", t.id)
        end
      end
    end
    
  end # end describe GET show
  
  describe "POST add_teacher" do
    it "will add the selected teacher to the given class if the current user is authorized" do
      # @id
      # @teacher_id
              
      post :add_teacher, { :id => @mock_clazz.id, :teacher_id => @unauthorized_teacher.id }
      
      @mock_clazz.reload
              
      assert @mock_clazz.teachers.include?(@unauthorized_teacher)
    end
  end
  
  describe "DELETE remove_teacher" do
    it "will remove the selected teacher from the given class if the current user is authorized" do
      # @id
      # @teacher_id
      
      teachers = [@authorized_teacher, @unauthorized_teacher]
      @mock_clazz.teachers = teachers
          
      delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => teachers.first.id }
  
      @mock_clazz.reload
          
      assert !@mock_clazz.teachers.include?(teachers.first)
    end
    
    it "will not let me remove the last teacher from the given class" do
      delete :remove_teacher, { :id => @mock_clazz.id, :teacher_id => @authorized_teacher.id }

      @mock_clazz.reload

      assert @mock_clazz.teachers.include?(@authorized_teacher)
      assert @response.body.include?(Portal::ClazzesController::CANNOT_REMOVE_LAST_TEACHER)
    end
  end
  
end