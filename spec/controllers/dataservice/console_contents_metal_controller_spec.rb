# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Dataservice::ConsoleContentsMetalController, type: :controller do

  # TODO: auto-generated
  describe '#create' do
    xit 'POST create' do
      post :create, id: Factory.create(:console_logger).to_param

      expect(response).to have_http_status(:ok)
    end
  end

end
