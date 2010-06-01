require 'spec_helper'

describe Portal::ClazzesController do
  integrate_views

  def mock_clazz(stubs={})
    mock_clazz = Factory.create(:portal_clazz, stubs) #mock_model(Portal::Clazz)
    #mock_clazz.stub!(stubs) unless stubs.empty?
    mock_clazz
      # 
      # @mock_school.stub!(stubs) unless stubs.empty?
      # @mock_school
  end
  
  describe "as administrator" do
    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
      
      # cleanup after previous tests
      Portal::Teacher.destroy_all
      User.destroy_all
      
      login_admin
      Admin::Project.should_receive(:default_project).and_return(@mock_project)
    end
  
    describe "GET show" do
      it "assigns the requested class as @portal_clazz" do
        mock_object = mock_clazz({ :teachers => [Factory.create(:portal_teacher)] })
        mock_id = mock_object.id
      
        get :show, :id => mock_id
        assigns[:portal_clazz].should == mock_object
      end
      
      it "shows the full class summary with edit button" do
        mock_object = mock_clazz({ :teachers => [Factory.create(:portal_teacher)] })
        mock_id = mock_object.id
        
        get :show, :id => mock_id
        
        with_tag("div#details_portal__clazz_#{mock_id}") do
          with_tag('div.action_menu') do
            with_tag('div.action_menu_right') do
              with_tag('a')
            end
          end
        end
      end
      
      it "shows the list of all teachers assigned to the requested class" do
        teacher1 = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher1"))
        teacher2 = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher2"))
        teachers = [teacher1, teacher2]
        mock_object = mock_clazz({ :teachers => teachers })
        mock_id = mock_object.id
        
        get :show, :id => mock_id
                
        with_tag("div#teachers_listing") do
          teachers.each do |teacher|
            with_tag("tr#portal__teacher_#{teacher.id}") do
              with_tag("a[onclick*=?]", remove_teacher_portal_clazz_path(mock_id, :teacher_id => teacher.id))
            end
          end
        end
      end
      
      it "populates the list of available teachers for ADD functionality" do
        mock_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "current_teacher"))
        
        mock_course = Factory.create(:portal_course)
        mock_object = mock_clazz({ :teachers => [mock_teacher], :course => mock_course })
        mock_id = mock_object.id
        
        1.upto 10 do |i|
          teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher#{i}"))
          mock_course.school.portal_teachers << teacher
        end
        
        get :show, :id => mock_id
                
        with_tag("select#teacher_id_selector[name=teacher_id]") do
          without_tag("option[value=?]", mock_teacher.id)
          
          mock_course.school.portal_teachers.each do |t|
            with_tag("option[value=?]", t.id)
          end
        end
      end
      
    end # end describe GET show
    
    describe "POST add_teacher" do
      it "will add the selected teacher to the given class" do
        # @id
        # @teacher_id
        mock_current_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "current_teacher"))
        mock_new_teacher = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "new_teacher"))
        mock_object = mock_clazz({ :teachers => [mock_current_teacher] })
        mock_id = mock_object.id
                
        post :add_teacher, { :id => mock_id, :teacher_id => mock_new_teacher.id }
        
        mock_object.reload
                
        assert mock_object.teachers.include?(mock_new_teacher)
      end
    end
    
    describe "DELETE remove_teacher" do
      it "will remove the selected teacher from the given class" do
        # @id
        # @teacher_id
        teacher1 = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher1"))
        teacher2 = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher2"))
        teachers = [teacher1, teacher2]
        mock_object = mock_clazz({ :teachers => teachers })
        mock_id = mock_object.id
            
        delete :remove_teacher, { :id => mock_id, :teacher_id => teachers.first.id }
    
        mock_object.reload
            
        assert !mock_object.teachers.include?(teachers.first.id)
      end
    end
  end
  
end