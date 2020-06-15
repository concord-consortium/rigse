require 'spec_helper'

describe MiscController do

  describe "GET preflight" do
  	it "returns the preflight page without error" do
  	  get :preflight
  	end
  end

  # TODO: auto-generated
  describe '#banner' do
    it 'GET banner' do
      get :banner, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#installer_report' do
    it 'GET installer_report' do
      get :installer_report, {}, {}

      expect(response).to have_http_status(:created)
    end
  end

  # TODO: auto-generated
  describe '#learner_proc_stats' do
    it 'GET learner_proc_stats' do
      get :learner_proc_stats, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#learner_proc' do
    it 'GET learner_proc' do
      get :learner_proc, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#stats' do
    it 'GET stats' do
      get :stats, {}, {}

      expect(response).to have_http_status(:not_acceptable)
    end
  end

  # TODO: auto-generated
  describe '#auth_check' do
    xit 'GET auth_check' do
      get :auth_check, provider: 'provider'

      expect(response).to have_http_status(:ok)
    end
  end

end
