require 'test_helper'

class VendorInterfacesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vendor_interfaces)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vendor_interface" do
    assert_difference('VendorInterface.count') do
      post :create, :vendor_interface => { }
    end

    assert_redirected_to vendor_interface_path(assigns(:vendor_interface))
  end

  test "should show vendor_interface" do
    get :show, :id => vendor_interfaces(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => vendor_interfaces(:one).to_param
    assert_response :success
  end

  test "should update vendor_interface" do
    put :update, :id => vendor_interfaces(:one).to_param, :vendor_interface => { }
    assert_redirected_to vendor_interface_path(assigns(:vendor_interface))
  end

  test "should destroy vendor_interface" do
    assert_difference('VendorInterface.count', -1) do
      delete :destroy, :id => vendor_interfaces(:one).to_param
    end

    assert_redirected_to vendor_interfaces_path
  end
end
