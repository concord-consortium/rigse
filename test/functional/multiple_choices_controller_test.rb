require 'test_helper'

class MultipleChoicesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:multiple_choices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create multiple_choice" do
    assert_difference('MultipleChoice.count') do
      post :create, :multiple_choice => { }
    end

    assert_redirected_to multiple_choice_path(assigns(:multiple_choice))
  end

  test "should show multiple_choice" do
    get :show, :id => multiple_choices(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => multiple_choices(:one).id
    assert_response :success
  end

  test "should update multiple_choice" do
    put :update, :id => multiple_choices(:one).id, :multiple_choice => { }
    assert_redirected_to multiple_choice_path(assigns(:multiple_choice))
  end

  test "should destroy multiple_choice" do
    assert_difference('MultipleChoice.count', -1) do
      delete :destroy, :id => multiple_choices(:one).id
    end

    assert_redirected_to multiple_choices_path
  end
end
