require 'test_helper'

class DataCollectorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:data_collectors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create data_collector" do
    assert_difference('DataCollector.count') do
      post :create, :data_collector => { }
    end

    assert_redirected_to data_collector_path(assigns(:data_collector))
  end

  test "should show data_collector" do
    get :show, :id => data_collectors(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => data_collectors(:one).id
    assert_response :success
  end

  test "should update data_collector" do
    put :update, :id => data_collectors(:one).id, :data_collector => { }
    assert_redirected_to data_collector_path(assigns(:data_collector))
  end

  test "should destroy data_collector" do
    assert_difference('DataCollector.count', -1) do
      delete :destroy, :id => data_collectors(:one).id
    end

    assert_redirected_to data_collectors_path
  end
end
