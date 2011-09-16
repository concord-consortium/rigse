require File.expand_path('../../../spec_helper', __FILE__)

describe Blog::BlogsController do
  describe "POST post_blog" do
    before(:each) do
      generate_default_project_and_jnlps_with_factories
      @project = Admin::Project.default_project
      
      @project.rpc_admin_login = "login"
      @project.rpc_admin_email = "email"
      @project.rpc_admin_password = "password"
      @project.word_press_url = "http://example.com"
      @project.save
      
      @user_id_response = mock(Net::HTTPOK, :code => 200, :body => "<string>200</string>")
      @user_id_error_response = mock(Net::HTTPOK, :code => 200, :body => "<string></string>")
      @content_post_response = mock(Net::HTTPOK, :code => 200, :body => "<string>384</string>")

      @post_params = {
        :blog_name => "myblog",
        :post_title => "This is my post title",
        :post_content => "This is some extended content.\nIt should look nice!"
      }

      @http_mock = mock(Net::HTTP)
    end
    
    it "skips posting to blog is rpc is not set" do
      @project.rpc_admin_login = nil
      @project.rpc_admin_email = nil
      @project.rpc_admin_password = nil
      @project.word_press_url = nil
      @project.save
        
      Net::HTTP.should_not_receive(:new)
      post :post_blog, @post_params
      response.should_not be_success
      response.code.to_i.should == 404
    end

    it "posts a blog as the current user" do
      Net::HTTP.should_receive(:new).twice.and_return(@http_mock)
      @http_mock.should_receive(:start).twice.and_yield(@http_mock)
      @http_mock.should_receive(:request).twice.and_return(@user_id_response, @content_post_response)
      post :post_blog, @post_params
      response.should be_success
    end

    it "returns an error when the current user doesn't exist in the blog" do
      Net::HTTP.should_receive(:new).once.and_return(@http_mock)
      @http_mock.should_receive(:start).once.and_yield(@http_mock)
      @http_mock.should_receive(:request).once.and_return(@user_id_error_response)
      post :post_blog, @post_params
      response.should_not be_success
      response.code.to_i.should == 404
    end
  end
end
