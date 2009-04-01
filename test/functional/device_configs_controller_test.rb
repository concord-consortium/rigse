require 'test_helper'

class DeviceConfigsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:device_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create device_config" do
    assert_difference('DeviceConfig.count') do
      post :create, :device_config => { }
    end

    assert_redirected_to device_config_path(assigns(:device_config))
  end

  test "should show device_config" do
    get :show, :id => device_configs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => device_configs(:one).to_param
    assert_response :success
  end

  test "should update device_config" do
    put :update, :id => device_configs(:one).to_param, :device_config => { }
    assert_redirected_to device_config_path(assigns(:device_config))
  end

  test "should destroy device_config" do
    assert_difference('DeviceConfig.count', -1) do
      delete :destroy, :id => device_configs(:one).to_param
    end

    assert_redirected_to device_configs_path
  end
end
