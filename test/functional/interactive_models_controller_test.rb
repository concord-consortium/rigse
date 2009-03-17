require 'test_helper'

class InteractiveModelsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:interactive_models)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create interactive_model" do
    assert_difference('InteractiveModel.count') do
      post :create, :interactive_model => { }
    end

    assert_redirected_to interactive_model_path(assigns(:interactive_model))
  end

  test "should show interactive_model" do
    get :show, :id => interactive_models(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => interactive_models(:one).id
    assert_response :success
  end

  test "should update interactive_model" do
    put :update, :id => interactive_models(:one).id, :interactive_model => { }
    assert_redirected_to interactive_model_path(assigns(:interactive_model))
  end

  test "should destroy interactive_model" do
    assert_difference('InteractiveModel.count', -1) do
      delete :destroy, :id => interactive_models(:one).id
    end

    assert_redirected_to interactive_models_path
  end
end
