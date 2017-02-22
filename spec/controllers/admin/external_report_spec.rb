require 'spec_helper'

describe Admin::ExternalReportsController do
  let(:admin_user)   { Factory.next(:admin_user)     }
  let(:simple_user)  { Factory.next(:confirmed_user) }
  let(:manager_user) { Factory.next(:manager_user)   }
  let(:report_id)    { 1 }

  describe "anonymous' access" do
    before (:each) do
      logout_user
    end

    describe "GET index" do
      it "wont alow the index, redirects to signin" do
        get :index
        assert_redirected_to :new_user_session
      end
    end

    describe "DELETE destroy" do
      it "wont allow delete, redirects to signin" do
        delete :destroy, :id => report_id
        assert_redirected_to :new_user_session
      end
    end

    describe "GET show" do
      it "wont allow show, redirects to signin" do
        get :show, :id => report_id
        assert_redirected_to :new_user_session
      end
    end

    describe "GET edit" do
      it "wont allow edit, redirects to signin" do
        get :show, :id => report_id
        assert_redirected_to :new_user_session
      end
    end

    describe "GET new" do
      it "wont allow new, redirects to signin" do
        get :new
        assert_redirected_to :new_user_session
      end
    end

    describe "PUT update" do
      it "wont allow update, redirects to signin" do
        put :update, :id => report_id, :report => {:params => 'params'}
        assert_redirected_to :new_user_session
      end
    end
  end

  describe "manager access" do
    before (:each) do
      sign_in manager_user
    end

    describe "GET index" do
      it "won't alow the index, redirects to root" do
        get :index
        assert_redirected_to :root
      end
    end

    describe "DELETE destroy" do
      it "wont allow delete, redirects to root" do
        delete :destroy, :id => report_id
        assert_redirected_to :root
      end
    end

    describe "GET show" do
      it "wont allow show, redirects to root" do
        get :show, :id => report_id
        assert_redirected_to :root
      end
    end

    describe "GET edit" do
      it "wont allow edit, redirects to root" do
        get :edit, :id => report_id
        assert_redirected_to :root
      end
    end

    describe "GET new" do
      it "wont allow new, redirects to root" do
        get :new
        assert_redirected_to :root
      end
    end

    describe "PUT update" do
      it "wont allow update, redirects to root" do
        put :update, :id => report_id, :report => {:params => 'params'}
        assert_redirected_to :root
      end
    end
  end

  describe "admin access" do
    let(:stubs) { {} }
    let(:mock_report) {
      mock_model ExternalReport, stubs
    }
    before (:each) do
      sign_in admin_user
    end

    describe "GET index" do
      it "will render the index" do
        get :index
        assert_response 200
        expect(response).to render_template("index")
      end
    end

    describe "DELETE destroy" do
      it "delete, and redirect back to index" do
        expect(ExternalReport).to receive(:find).and_return(mock_report)
        delete :destroy, :id => report_id
        assert_redirected_to action: :index
      end
    end

    describe "GET show" do
      it "redners the show template" do
        expect(ExternalReport).to receive(:find).and_return(mock_report)
        get :show, :id => report_id
        expect(assigns[:report]).to eq mock_report
        expect(response).to render_template("show")
      end
    end

    describe "GET edit" do
      it "renders the edit template" do
        expect(ExternalReport).to receive(:find).and_return(mock_report)
        get :edit, :id => report_id
        expect(assigns[:report]).to eq mock_report
        expect(response).to render_template("edit")
      end
    end

    describe "GET new" do
      it "renders the new form" do
        get :new
        expect(response).to render_template("new")
        assert_response 200
      end
    end

    describe "PUT update" do
      let(:stubs) {{ update_attributes: true }}
      it "updates the model, redirects to index" do
        expect(ExternalReport).to receive(:find).and_return(mock_report)
        put :update, :id => report_id, :report => {:params => 'params'}
        assert_redirected_to action: :index
      end
    end
  end

end
