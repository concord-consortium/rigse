# encoding: utf-8
require 'spec_helper'

RSpec.describe API::V1::StudentsController, type: :controller do
  let(:student) { FactoryBot.create(:full_portal_student) }

  describe "POST #check_password" do
    let(:params) do
      {
        'id' => student.id,
        'password' => 'password'
      }
    end

    context "with valid password" do
      it "returns ok" do
        post :check_password, params
        expect(response.status).to eq(200)
      end
    end

    context "with invalid password" do
      before { params['password'] = 'wrong_password' }
      it "returns error" do
        post :check_password, params
        expect(response.status).to eq(401)
      end
    end

    context "with invalid student id" do
      before { params['id'] = 12321321 }
      it "returns error" do
        post :check_password, params
        expect(response.status).to eq(404)
      end
    end
  end


  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create, {}, {}

      expect(response).to have_http_status(:bad_request)
    end
  end

  # TODO: auto-generated
  describe '#check_class_word' do
    it 'GET check_class_word' do
      get :check_class_word, {}, {}

      expect(response).to have_http_status(:bad_request)
    end
  end

end
