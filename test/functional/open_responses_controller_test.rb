require 'test_helper'

class OpenResponsesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:open_responses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create open_response" do
    assert_difference('OpenResponse.count') do
      post :create, :open_response => { }
    end

    assert_redirected_to open_response_path(assigns(:open_response))
  end

  test "should show open_response" do
    get :show, :id => open_responses(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => open_responses(:one).id
    assert_response :success
  end

  test "should update open_response" do
    put :update, :id => open_responses(:one).id, :open_response => { }
    assert_redirected_to open_response_path(assigns(:open_response))
  end

  test "should destroy open_response" do
    assert_difference('OpenResponse.count', -1) do
      delete :destroy, :id => open_responses(:one).id
    end

    assert_redirected_to open_responses_path
  end
end
