require 'test_helper'

class ActivityStepsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:activity_steps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create activity_steps" do
    assert_difference('ActivitySteps.count') do
      post :create, :activity_steps => { }
    end

    assert_redirected_to activity_steps_path(assigns(:activity_steps))
  end

  test "should show activity_steps" do
    get :show, :id => activity_steps(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => activity_steps(:one).id
    assert_response :success
  end

  test "should update activity_steps" do
    put :update, :id => activity_steps(:one).id, :activity_steps => { }
    assert_redirected_to activity_steps_path(assigns(:activity_steps))
  end

  test "should destroy activity_steps" do
    assert_difference('ActivitySteps.count', -1) do
      delete :destroy, :id => activity_steps(:one).id
    end

    assert_redirected_to activity_steps_path
  end
end
