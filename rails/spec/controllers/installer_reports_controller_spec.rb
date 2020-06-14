# frozen_string_literal: false

require 'spec_helper'

RSpec.describe InstallerReportsController, type: :controller do

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      login_admin

      get :index

      expect(response).to have_http_status(:ok)
    end
  end

end
