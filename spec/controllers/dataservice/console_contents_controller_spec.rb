require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::ConsoleContentsController do

  def mock_console_content(stubs={})
    @mock_console_content ||= mock_model(Dataservice::ConsoleContent, stubs)
  end

  describe "GET index" do
    it "assigns all dataservice_console_contents as @dataservice_console_contents" do
      Dataservice::ConsoleContent.should_receive(:find).with(:all, hash_including(will_paginate_params(:limit=>5))).and_return([mock_console_content])
      login_admin
      get :index
      assigns[:dataservice_console_contents].should == [mock_console_content]
    end
  end

  describe "GET show" do
    it "assigns the requested console_content as @dataservice_console_content" do
      Dataservice::ConsoleContent.should_receive(:find).with("37").and_return(mock_console_content)
      login_admin
      get :show, :id => "37"
      assigns[:dataservice_console_content].should equal(mock_console_content)
    end
  end

  describe "GET new" do
    it "assigns a new console_content as @dataservice_console_content" do
      Dataservice::ConsoleContent.should_receive(:new).and_return(mock_console_content)
      login_admin
      get :new
      assigns[:dataservice_console_content].should equal(mock_console_content)
    end
  end

  describe "GET edit" do
    it "assigns the requested console_content as @dataservice_console_content" do
      Dataservice::ConsoleContent.should_receive(:find).with("37").and_return(mock_console_content)
      login_admin
      get :edit, :id => "37"
      assigns[:dataservice_console_content].should equal(mock_console_content)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created console_content as @dataservice_console_content" do
        Dataservice::ConsoleContent.should_receive(:new).with({'these' => 'params'}).and_return(mock_console_content(:save => true))
        login_admin
        post :create, :dataservice_console_content => {:these => 'params'}
        assigns[:dataservice_console_content].should equal(mock_console_content)
      end

      it "redirects to the created console_content" do
        Dataservice::ConsoleContent.should_receive(:new).and_return(mock_console_content(:save => true))
        login_admin
        post :create, :dataservice_console_content => {}
        response.should redirect_to(dataservice_console_content_url(mock_console_content))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved console_content as @dataservice_console_content" do
        Dataservice::ConsoleContent.should_receive(:new).with({'these' => 'params'}).and_return(mock_console_content(:save => false))
        login_admin
        post :create, :dataservice_console_content => {:these => 'params'}
        assigns[:dataservice_console_content].should equal(mock_console_content)
      end

      it "re-renders the 'new' template" do
        Dataservice::ConsoleContent.should_receive(:new).and_return(mock_console_content(:save => false))
        login_admin
        post :create, :dataservice_console_content => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested console_content" do
        Dataservice::ConsoleContent.should_receive(:find).with("37").and_return(mock_console_content)
        mock_console_content.should_receive(:update_attributes).with({'these' => 'params'})
        login_admin
        put :update, :id => "37", :dataservice_console_content => {:these => 'params'}
      end

      it "assigns the requested console_content as @dataservice_console_content" do
        Dataservice::ConsoleContent.should_receive(:find).and_return(mock_console_content(:update_attributes => true))
        login_admin
        put :update, :id => "1"
        assigns[:dataservice_console_content].should equal(mock_console_content)
      end

      it "redirects to the console_content" do
        Dataservice::ConsoleContent.should_receive(:find).and_return(mock_console_content(:update_attributes => true))
        login_admin
        put :update, :id => "1"
        response.should redirect_to(dataservice_console_content_url(mock_console_content))
      end
    end

    describe "with invalid params" do
      it "updates the requested console_content" do
        Dataservice::ConsoleContent.should_receive(:find).with("37").and_return(mock_console_content)
        mock_console_content.should_receive(:update_attributes).with({'these' => 'params'})
        login_admin
        put :update, :id => "37", :dataservice_console_content => {:these => 'params'}
      end

      it "assigns the console_content as @dataservice_console_content" do
        Dataservice::ConsoleContent.should_receive(:find).and_return(mock_console_content(:update_attributes => false))
        login_admin
        put :update, :id => "1"
        assigns[:dataservice_console_content].should equal(mock_console_content)
      end

      it "re-renders the 'edit' template" do
        Dataservice::ConsoleContent.should_receive(:find).and_return(mock_console_content(:update_attributes => false))
        login_admin
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested console_content" do
      Dataservice::ConsoleContent.should_receive(:find).with("37").and_return(mock_console_content)
      mock_console_content.should_receive(:destroy)
      login_admin
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_console_contents list" do
      Dataservice::ConsoleContent.should_receive(:find).and_return(mock_console_content(:destroy => true))
      login_admin
      delete :destroy, :id => "1"
      response.should redirect_to(dataservice_console_contents_url)
    end
  end

end
