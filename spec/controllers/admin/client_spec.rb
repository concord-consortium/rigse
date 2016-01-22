require 'spec_helper'

describe Admin::ClientsController do
  let(:admin_user)   { Factory.next(:admin_user)     }
  let(:simple_user)  { Factory.next(:confirmed_user) }
  let(:manager_user) { Factory.next(:manager_user)   }
  let(:client_id)    { 1 }

  describe "anonymous' access" do
    before (:each) do
      logout_user
    end

    describe "GET index" do
      it "wont alow the index, redirects home" do
        get :index
        assert_redirected_to :home
      end
    end

    describe "DELETE destroy" do
      it "wont allow delete, redirects home" do
        delete :destroy, :id => client_id
        assert_redirected_to :home
      end
    end

    describe "GET show" do
      it "wont allow show, redirects home" do
        get :show, :id => client_id
        assert_redirected_to :home
      end
    end

    describe "GET edit" do
      it "wont allow edit, redirects home" do
        get :show, :id => client_id
        assert_redirected_to :home
      end
    end

    describe "GET new" do
      it "wont allow new, redirects home" do
        get :new
        assert_redirected_to :home
      end
    end

    describe "PUT update" do
      it "wont allow update, redirects home" do
        put :update, :id => client_id, :client => {:params => 'params'}
        assert_redirected_to :home
      end
    end
  end

  describe "manager access" do
    before (:each) do
      sign_in manager_user
    end

    describe "GET index" do
      it "won't alow the index, redirects home" do
        get :index
        assert_redirected_to :home
      end
    end

    describe "DELETE destroy" do
      it "wont allow delete, redirects home" do
        delete :destroy, :id => client_id
        assert_redirected_to :home
      end
    end

    describe "GET show" do
      it "wont allow show, redirects home" do
        get :show, :id => client_id
        assert_redirected_to :home
      end
    end

    describe "GET edit" do
      it "wont allow edit, redirects home" do
        get :edit, :id => client_id
        assert_redirected_to :home
      end
    end

    describe "GET new" do
      it "wont allow new, redirects home" do
        get :new
        assert_redirected_to :home
      end
    end

    describe "PUT update" do
      it "wont allow update, redirects home" do
        put :update, :id => client_id, :client => {:params => 'params'}
        assert_redirected_to :home
      end
    end
  end

  describe "admin access" do
    let(:stubs) { {} }
    let(:mock_client) {
      mock_model Client, stubs
    }
    before (:each) do
      sign_in admin_user
    end

    describe "GET index" do
      it "will render the index" do
        get :index
        assert_response 200
        response.should render_template("index")
      end
    end

    describe "DELETE destroy" do
      it "delete, and redirect back to index" do
        Client.should_receive(:find).and_return(mock_client)
        delete :destroy, :id => client_id
        assert_redirected_to action: :index
      end
    end

    describe "GET show" do
      it "redners the show template" do
        Client.should_receive(:find).and_return(mock_client)
        get :show, :id => client_id
        assigns[:client].should eq mock_client
        response.should render_template("show")
      end
    end

    describe "GET edit" do
      it "renders the edit template" do
        Client.should_receive(:find).and_return(mock_client)
        get :edit, :id => client_id
        assigns[:client].should eq mock_client
        response.should render_template("edit")
      end
    end

    describe "GET new" do
      it "renders the new form" do
        get :new
        response.should render_template("new")
        assert_response 200
      end
    end

    describe "PUT update" do
      let(:stubs) {{ update_attributes: true }}
      it "updates the model, redirects to index" do
        Client.should_receive(:find).and_return(mock_client)
        put :update, :id => client_id, :client => {:params => 'params'}
        assert_redirected_to action: :index
      end
    end
  end

end
