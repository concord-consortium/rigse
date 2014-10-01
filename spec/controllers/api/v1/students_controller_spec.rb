# encoding: utf-8
require 'spec_helper'

describe API::V1::StudentsController do
  let(:student) { Factory(:full_portal_student) }

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

end
