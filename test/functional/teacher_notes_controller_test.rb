require 'test_helper'

class TeacherNotesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teacher_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create teacher_note" do
    assert_difference('TeacherNote.count') do
      post :create, :teacher_note => { }
    end

    assert_redirected_to teacher_note_path(assigns(:teacher_note))
  end

  test "should show teacher_note" do
    get :show, :id => teacher_notes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => teacher_notes(:one).to_param
    assert_response :success
  end

  test "should update teacher_note" do
    put :update, :id => teacher_notes(:one).to_param, :teacher_note => { }
    assert_redirected_to teacher_note_path(assigns(:teacher_note))
  end

  test "should destroy teacher_note" do
    assert_difference('TeacherNote.count', -1) do
      delete :destroy, :id => teacher_notes(:one).to_param
    end

    assert_redirected_to teacher_notes_path
  end
end
