require 'test_helper'

class CalibrationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calibrations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create calibration" do
    assert_difference('Calibration.count') do
      post :create, :calibration => { }
    end

    assert_redirected_to calibration_path(assigns(:calibration))
  end

  test "should show calibration" do
    get :show, :id => calibrations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => calibrations(:one).to_param
    assert_response :success
  end

  test "should update calibration" do
    put :update, :id => calibrations(:one).to_param, :calibration => { }
    assert_redirected_to calibration_path(assigns(:calibration))
  end

  test "should destroy calibration" do
    assert_difference('Calibration.count', -1) do
      delete :destroy, :id => calibrations(:one).to_param
    end

    assert_redirected_to calibrations_path
  end
end
