# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::PeriodicBundleLoggersController, type: :controller do

  # TODO: auto-generated
  describe '#show' do
    xit 'GET show' do
      get :show, id: FactoryGirl.create(:periodic_bundle_logger).to_param

      expect(response).to have_http_status(:ok)
    end
  end

end
