require 'test_helper'

class DataFiltersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:data_filters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create data_filter" do
    assert_difference('DataFilter.count') do
      post :create, :data_filter => { }
    end

    assert_redirected_to data_filter_path(assigns(:data_filter))
  end

  test "should show data_filter" do
    get :show, :id => data_filters(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => data_filters(:one).to_param
    assert_response :success
  end

  test "should update data_filter" do
    put :update, :id => data_filters(:one).to_param, :data_filter => { }
    assert_redirected_to data_filter_path(assigns(:data_filter))
  end

  test "should destroy data_filter" do
    assert_difference('DataFilter.count', -1) do
      delete :destroy, :id => data_filters(:one).to_param
    end

    assert_redirected_to data_filters_path
  end
end
