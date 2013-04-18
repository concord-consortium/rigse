require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::StudentClazzesController do
  render_views
    
  def mock_clazz(stubs={})
    mock_clazz = Factory.create(:portal_clazz, stubs) #mock_model(Portal::Clazz)
    #mock_clazz.stub!(stubs) unless stubs.empty?

    mock_clazz
  end
  
  describe "Delete remove a student" do
    before(:each) do
      @mock_semester = Factory.create(:portal_semester, :name => "Fall")
      @mock_school = Factory.create(:portal_school, :semesters => [@mock_semester])
      @authorized_teacher = Factory.create(:portal_teacher, :user => Factory.create(:confirmed_user, :login => "authorized_teacher"), :schools => [@mock_school])
      @authorized_student = Factory.create(:portal_student, :user =>Factory.create(:confirmed_user, :login => "authorized_student"))
      
      @mock_clazz_name = "Random Test Class"
      @mock_course = Factory.create(:portal_course, :name => @mock_clazz_name, :school => @mock_school)
      @mock_clazz = mock_clazz({ :name => @mock_clazz_name, :teachers => [@authorized_teacher], :course => @mock_course })
      
      @authorized_student.add_clazz(@mock_clazz)
      @mock_clazz.reload
      @mock_student_clazz = Portal::StudentClazz.find_by_clazz_id_and_student_id(@mock_clazz.id, @authorized_student.id)
    end

    it "Remove a student from a class" do
      post_params = {
        :id => @mock_student_clazz.id.to_s
      }
      delete :destroy, post_params
    end
  end
end