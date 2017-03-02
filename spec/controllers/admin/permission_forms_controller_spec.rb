require 'spec_helper'

describe Admin::PermissionFormsController do
  before(:each) do
    @cohort1 = Factory.create(:admin_cohort)
    @cohort2 = Factory.create(:admin_cohort)
    @project1 = Factory.create(:project)
    @project1.cohorts << @cohort1
    @project2 = Factory.create(:project)
    @project2.cohorts << @cohort2
    @form1 = Factory.create(:permission_form, project: @project1)
    @form2 = Factory.create(:permission_form, project: @project2)
    @teacher1 = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher1"))
    @teacher1.cohorts << @cohort1
    @teacher_view1 = Admin::PermissionFormsController::TeacherView.new(@teacher1)
    @teacher2 = Factory.create(:portal_teacher, :user => Factory.create(:user, :login => "teacher2"))
    @teacher_view2 = Admin::PermissionFormsController::TeacherView.new(@teacher2)
    @teacher2.cohorts << @cohort2
  end

  # User variable is overwritten by some test cases.
  let(:user) { Factory.next(:admin_user) }
  before(:each) { sign_in user }

  describe "GET index" do
    # It means that we're looking for teachers whose name, last name or *login* is "teacher".
    let(:index_form_params) do
      {
        form: {
          name: 'teacher'
        }
      }
    end

    describe "when user is an admin" do
      it "lists all forms, projects and teachers" do
        get :index, index_form_params
        expect(assigns(:projects)).to eq([@project1, @project2])
        expect(assigns(:permission_forms)).to eq([@form1, @form2])
        expect(assigns(:teachers)).to eq([@teacher_view1, @teacher_view2])
      end
    end

    describe "when user is a project admin" do
      let(:user) do
        user = Factory.create(:confirmed_user)
        user.add_role_for_project('admin', @project1)
        user
      end

      it "lists forms, projects and teachers that belong to his project" do
        get :index, index_form_params
        expect(assigns(:projects)).to eq([@project1])
        expect(assigns(:permission_forms)).to eq([@form1])
        expect(assigns(:teachers)).to eq([@teacher_view1])
      end
    end

    describe "when user is a project researcher" do
      let(:user) do
        user = Factory.create(:confirmed_user)
        user.add_role_for_project('researcher', @project2)
        user
      end

      it "lists forms, projects and teachers that belong to his project" do
        get :index, index_form_params
        expect(assigns(:projects)).to eq([@project2])
        expect(assigns(:permission_forms)).to eq([@form2])
        expect(assigns(:teachers)).to eq([@teacher_view2])
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new permission form" do
        expect {
          post :create, {
            portal_permission: {
              name: 'test',
              url: 'http://concord.org',
              project_id: @project1.id
            }
          }
        }.to change(Portal::PermissionForm, :count).by(1)
        new_form = Portal::PermissionForm.last
        expect(new_form.name).to eq('test')
        expect(new_form.url).to eq('http://concord.org')
        expect(new_form.project).to eq(@project1)
      end
    end
  end

  describe "GET remove_form" do
    it "destroys the requested permission form" do
      expect {
        get :remove_form, {id: @form1}
      }.to change(Portal::PermissionForm, :count).by(-1)
    end
  end
end