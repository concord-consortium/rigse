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
            with_tag("tr#portal__teacher_#{teacher.id}")
          end
        end
      end
      
    end # end describe GET show
    
    describe "POST add_teacher" do
    end
    
    describe "DELETE remove_teacher" do
    end
  end
  
end