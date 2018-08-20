# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::LearnerDetailsController, type: :controller do

  let(:admin_user)   { Factory.next(:admin_user)     }
  before (:each) do
    sign_in admin_user
  end

  # TODO: auto-generated
  describe '#show' do
    xit 'GET show' do
      get :show, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

end
