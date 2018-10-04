# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::PeriodicBundleLoggersMetalController, type: :controller do

  # TODO: auto-generated
  describe '#session_end_notification' do
    xit 'GET session_end_notification' do
      get :session_end_notification, id: FactoryBot.create(:periodic_bundle_logger).to_param

      expect(response).to have_http_status(:ok)
    end
  end

end
