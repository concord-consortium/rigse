require 'test_helper'

class PhysicalUnitsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:physical_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create physical_unit" do
    assert_difference('PhysicalUnit.count') do
      post :create, :physical_unit => { }
    end

    assert_redirected_to physical_unit_path(assigns(:physical_unit))
  end

  test "should show physical_unit" do
    get :show, :id => physical_units(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => physical_units(:one).to_param
    assert_response :success
  end

  test "should update physical_unit" do
    put :update, :id => physical_units(:one).to_param, :physical_unit => { }
    assert_redirected_to physical_unit_path(assigns(:physical_unit))
  end

  test "should destroy physical_unit" do
    assert_difference('PhysicalUnit.count', -1) do
      delete :destroy, :id => physical_units(:one).to_param
    end

    assert_redirected_to physical_units_path
  end
end
