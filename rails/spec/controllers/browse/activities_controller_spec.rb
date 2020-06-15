# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Browse::ActivitiesController, type: :controller do

  # TODO: auto-generated
  describe '#show' do
    xit 'GET show' do
      get :show, id: FactoryBot.create(:activity).to_param

      expect(response).to have_http_status(:ok)
    end
  end

end
