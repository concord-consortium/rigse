require 'test_helper'

class XhtmlsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:xhtmls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create xhtml" do
    assert_difference('Xhtml.count') do
      post :create, :xhtml => { }
    end

    assert_redirected_to xhtml_path(assigns(:xhtml))
  end

  test "should show xhtml" do
    get :show, :id => xhtmls(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => xhtmls(:one).id
    assert_response :success
  end

  test "should update xhtml" do
    put :update, :id => xhtmls(:one).id, :xhtml => { }
    assert_redirected_to xhtml_path(assigns(:xhtml))
  end

  test "should destroy xhtml" do
    assert_difference('Xhtml.count', -1) do
      delete :destroy, :id => xhtmls(:one).id
    end

    assert_redirected_to xhtmls_path
  end
end
